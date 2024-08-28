//
//  SNRequest.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

public struct SNRequest {
    public var path: String
    public var method: SNMethod
    public var headers: [SNHeader]
    public var parameters: SNParameters?
    
    public init(path: String, method: SNMethod = .get, headers: [SNHeader] = [], parameters: SNParameters? = nil) {
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
}

extension SNRequest {
    func urlRequest(base: URL) -> URLRequest {
        var url = base
        if #available(iOS 16.0, *) {
            url = url.appending(path: path)
        } else {
            url = url.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.name)
        }
        let userAgent: SNHeader = .defaultUserAgent
        let acceptEncoding: SNHeader = .defaultAcceptEncoding
        let acceptLanguage: SNHeader = .defaultAcceptLanguage
        request.addValue(userAgent.value, forHTTPHeaderField: userAgent.name)
        request.addValue(acceptEncoding.value, forHTTPHeaderField: acceptEncoding.name)
        request.addValue(acceptLanguage.value, forHTTPHeaderField: acceptLanguage.name)

        //print("Header fields: \(request.allHTTPHeaderFields)")
        if let parameters = parameters {
            switch method {
            case .get:
                if #available(iOS 16.0, *) {
                    request.url = url.appending(queryItems: parameters.queryItems)
                } else {
                    let urlString = url.absoluteString.appending("?\(parameters.query)")
                    request.url = URL(string: urlString)!
                }
            case .post:
                request.httpBody = parameters.body
            }
        }
        
        return request
    }
}
