//
//  SimpleNetwork+Request.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

extension SimpleNetworkManager {
    
    public func request<O: Decodable>(
        _ request: SNRequest,
        retryCount: Int = 0,
        retryDelay: TimeInterval = 1.0
    ) async -> SNResponse<O> {
        return await performRequest(request, retryCount: retryCount, retryDelay: retryDelay)
    }
    
    private func performRequest<O: Decodable>(
        _ request: SNRequest,
        retryCount: Int,
        retryDelay: TimeInterval
    ) async -> SNResponse<O> {
        do {
            printDebug("Making request\n\(request.debugDescription)")
            let (data, response) = try await session.data(for: request.urlRequest(base: base))
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let resp: SNResponse<O> = SNResponse(error: SNError.unknown)
                printDebug("Received response\n\(resp.debugDescription)")
                return resp
            }
            
            // Check if status code is valid
            if !validateStatus(httpResponse.statusCode) && retryCount > 0 && shouldRetryOnStatus(httpResponse.statusCode, method: request.method) {
                printDebug("Request failed with status \(httpResponse.statusCode), retrying... (\(retryCount) attempts left)")
                let clampedDelay = max(0, retryDelay)
                let nanos = UInt64(clampedDelay * 1_000_000_000)
                try await Task.sleep(nanoseconds: min(nanos, UInt64.max))
                return await performRequest(request, retryCount: retryCount - 1, retryDelay: retryDelay)
            }
            
            let resp: SNResponse<O> = SNResponse(
                data: data,
                response: response,
                validateStatus: validateStatus
            )
            printDebug("Received response\n\(resp.debugDescription)")
            return resp
        } catch(let error) {
            // Check if we should retry
            if retryCount > 0 && shouldRetry(error: error) {
                printDebug("Request failed with error \(error), retrying... (\(retryCount) attempts left)")
                let clampedDelay = max(0, retryDelay)
                let nanos = UInt64(clampedDelay * 1_000_000_000)
                do {
                    try await Task.sleep(nanoseconds: min(nanos, UInt64.max))
                } catch {
                    printDebug("Retry sleep cancelled, returning error")
                }
                return await performRequest(request, retryCount: retryCount - 1, retryDelay: retryDelay)
            }
            
            let resp: SNResponse<O> = SNResponse(error: error)
            printDebug("Received response\n\(resp.debugDescription)")
            return resp
        }
    }
    
    public func request<O: Decodable>(
        _ request: SNRequest,
        retryCount: Int = 0,
        retryDelay: TimeInterval = 1.0,
        result: @escaping (SNResponse<O>) -> Void
    ) {
        performRequest(request, retryCount: retryCount, retryDelay: retryDelay, result: result)
    }
    
    private func performRequest<O: Decodable>(
        _ request: SNRequest,
        retryCount: Int,
        retryDelay: TimeInterval,
        result: @escaping (SNResponse<O>) -> Void
    ) {
        let task = session.dataTask(with: request.urlRequest(base: base)) { data, response, error in
            
            // Handle network error
            if let error = error {
                // Check if we should retry
                if retryCount > 0 && self.shouldRetry(error: error) {
                    self.printDebug("Request failed with error \(error), retrying... (\(retryCount) attempts left)")
                    let clampedDelay = max(0, retryDelay)
                    DispatchQueue.global().asyncAfter(deadline: .now() + clampedDelay) {
                        self.performRequest(request, retryCount: retryCount - 1, retryDelay: retryDelay, result: result)
                    }
                    return
                }
                
                let resp: SNResponse<O> = SNResponse(error: error)
                self.printDebug("Received response\n\(resp.debugDescription)")
                result(resp)
                return
            }
            
            // Handle missing response
            guard let httpResponse = response as? HTTPURLResponse else {
                let resp: SNResponse<O> = SNResponse(error: SNError.unknown)
                self.printDebug("Received response\n\(resp.debugDescription)")
                result(resp)
                return
            }
            
            // Handle missing data (treat nil as empty)
            let data = data ?? Data()
            
            // Check if status code is valid and retry if needed
            if !self.validateStatus(httpResponse.statusCode) && retryCount > 0 && self.shouldRetryOnStatus(httpResponse.statusCode, method: request.method) {
                self.printDebug("Request failed with status \(httpResponse.statusCode), retrying... (\(retryCount) attempts left)")
                let clampedDelay = max(0, retryDelay)
                DispatchQueue.global().asyncAfter(deadline: .now() + clampedDelay) {
                    self.performRequest(request, retryCount: retryCount - 1, retryDelay: retryDelay, result: result)
                }
                return
            }
            
            let resp: SNResponse<O> = SNResponse(
                data: data,
                response: response,
                validateStatus: self.validateStatus
            )
            self.printDebug("Received response\n\(resp.debugDescription)")
            result(resp)
        }
        task.resume()
    }
    
    private func shouldRetryOnStatus(_ code: Int, method: SNMethod) -> Bool {
        guard [408, 429].contains(code) || (500...599).contains(code) else { return false }
        
        let idempotentMethods: Set<SNMethod> = [.get, .head, .put, .delete]
        return idempotentMethods.contains(method)
    }
    
    private func shouldRetry(error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else {
            return false
        }
        switch nsError.code {
        case NSURLErrorTimedOut,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorNotConnectedToInternet:
            return true
        default:
            return false
        }
    }
}
