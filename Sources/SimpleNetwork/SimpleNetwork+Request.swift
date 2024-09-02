//
//  SimpleNetwork+Request.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

extension SimpleNetwork {
    
    @available(iOS 13.0.0, *)
    public func request<O: Decodable>(_ request: SNRequest) async -> SNResponse<O> {
        do {
            printDebug("Making request\n\(request.debugDescription)")
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest(base: base))
            let resp: SNResponse<O> = SNResponse(data: data, response: response)
            printDebug("Received response\n\(resp.debugDescription)")
            return resp
        } catch(let error) {
            //print("Error: \(error.localizedDescription)")
            let resp: SNResponse<O> = SNResponse(error: error)
            printDebug("Received response\n\(resp.debugDescription)")
            return resp
        }
    }
    
    public func request<O: Decodable>(_ request: SNRequest, result: @escaping (SNResponse<O>) -> Void) {
        let task = URLSession.shared.dataTask(with: request.urlRequest(base: base)) { data, response, error in
            if let error = error {
                //print("Error: \(error.localizedDescription)")
                let resp: SNResponse<O> = SNResponse(error: error)
                self.printDebug("Received response\n\(resp.debugDescription)")
                result(resp)
            } else if let data = data {
                //print("Data received: \(data)")
                let resp: SNResponse<O> = SNResponse(data: data, response: response)
                self.printDebug("Received response\n\(resp.debugDescription)")
                result(resp)
            }
        }
        task.resume()
    }
}
