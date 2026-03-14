//
//  SNParameters.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

/// Protocol for parameters that can be encoded for requests
public protocol SNParametersProtocol {
    func encode() throws -> Data
    var queryItems: [URLQueryItem] { get }
}



/// Simple dictionary-based parameters
public typealias SNParameters = [String: String]

extension SNParameters: SNParametersProtocol {
    public func encode() throws -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: self)
        } catch {
            throw SNError.encodingFailed
        }
    }
    
    public var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

extension SNParameters {
    internal var query: String {
        map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
    }
    
    internal var body: Data? {
        try? encode()
    }
}
