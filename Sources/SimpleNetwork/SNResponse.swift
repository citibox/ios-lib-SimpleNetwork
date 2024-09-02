//
//  SNRespone.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

public struct SNResponse<Object: Decodable> {
    public var url: URL?
    public var result: Result<Object?, SNError>
    public var status: Int = 0
    public var headers: [SNHeader] = []
    public var data: Data?
    
    internal init(data: Data, response: URLResponse?) {
        self.url = response?.url
        self.data = data
        if let httpResponse = response as? HTTPURLResponse {
            status = httpResponse.statusCode
            headers = httpResponse.allHeaderFields.map({ SNHeader(name: $0.key as? String ?? "", value: $0.value as? String ?? "") })
        }
        
        let decoder = JSONDecoder()
        if Object.self != SNEmpty.self {
            do {
                let object = try decoder.decode(Object.self, from: data)
                result = .success(object)
            } catch(let decodingError) {
                result = .failure(.cannotDecode)
            }
        } else {
            result = .success(SNEmpty.value as? Object)
        }
    }
    
    internal init(error: Error) {
        switch (error as NSError).code {
        case NSURLErrorNotConnectedToInternet:
            result = .failure(.noInternet)
        case NSURLErrorNetworkConnectionLost:
            result = .failure(.connectionLost)
        case NSURLErrorTimedOut:
            result = .failure(.timeout)
        case NSURLErrorUnknown:
            result = .failure(.unknown)
        default:
            result = .failure(.unknown)
        }
    }
}

extension SNResponse: CustomDebugStringConvertible {
    public var debugDescription: String {
        "<SNResponse \(url?.debugDescription ?? "No URL!")\n\t\(status) - \(result)\n\tHeaders: \(headers)\n\tJSONData: \(( try? JSONSerialization.jsonObject(with: data ?? Data())) ?? "Empty")\n>"
    }
}
