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
            let (data, response) = try await URLSession.shared.data(for: request.urlRequest(base: base))
            return SNResponse(data: data, response: response)
        } catch(let error) {
            //print("Error: \(error.localizedDescription)")
            return SNResponse(error: error)
        }
    }
    
    public func request<O: Decodable>(_ request: SNRequest, result: @escaping (SNResponse<O>) -> Void) {
        let task = URLSession.shared.dataTask(with: request.urlRequest(base: base)) { data, response, error in
            if let error = error {
                //print("Error: \(error.localizedDescription)")
                result(SNResponse(error: error))
            } else if let data = data {
                //print("Data received: \(data)")
                result(SNResponse(data: data, response: response))
            }
        }
        task.resume()
    }
}
