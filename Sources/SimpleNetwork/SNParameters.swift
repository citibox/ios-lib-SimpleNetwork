//
//  SNParameters.swift
//
//
//  Created by Marcos Alba on 28/8/24.
//

import Foundation

public typealias SNParameters = [String: String]

extension SNParameters {
    internal var query: String {
        map({ "\($0.key)=\($0.value)" }).joined(separator: "&")
    }
    
    internal var queryItems: [URLQueryItem] {
        map({ URLQueryItem(name: $0.key, value: $0.value) })
    }
    
    internal var body: Data? {
        try? JSONEncoder().encode(self)
    }
}
