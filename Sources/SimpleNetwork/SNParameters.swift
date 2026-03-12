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

extension SNParametersProtocol where Self: Encodable {
    public func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    public var queryItems: [URLQueryItem] {
        guard let dict = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: dict) as? [String: Any] else {
            return []
        }
        return json.map { URLQueryItem(name: $0.key, value: String(describing: $0.value)) }
    }
}

/// Simple dictionary-based parameters
public typealias SNParameters = [String: String]

extension SNParameters: SNParametersProtocol {
    public func encode() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
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
