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
            if !validateStatus(httpResponse.statusCode) && retryCount > 0 {
                printDebug("Request failed with status \(httpResponse.statusCode), retrying... (\(retryCount) attempts left)")
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
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
                try? await Task.sleep(nanoseconds: UInt64(retryDelay * 1_000_000_000))
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
        let task = session.dataTask(with: request.urlRequest(base: base)) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // Handle network error
            if let error = error {
                // Check if we should retry
                if retryCount > 0 && self.shouldRetry(error: error) {
                    self.printDebug("Request failed with error \(error), retrying... (\(retryCount) attempts left)")
                    DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
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
            
            // Handle missing data
            guard let data = data else {
                let resp: SNResponse<O> = SNResponse(error: SNError.unknown)
                self.printDebug("Received response\n\(resp.debugDescription)")
                result(resp)
                return
            }
            
            // Check if status code is valid and retry if needed
            if !self.validateStatus(httpResponse.statusCode) && retryCount > 0 {
                self.printDebug("Request failed with status \(httpResponse.statusCode), retrying... (\(retryCount) attempts left)")
                DispatchQueue.global().asyncAfter(deadline: .now() + retryDelay) {
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
