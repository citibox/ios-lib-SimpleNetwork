//
//  SimpleNetwork.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import Foundation

public let version = "1.0.0"

/// Main network client
public class SimpleNetworkManager {
    internal let base: URL?
    internal let session: URLSession
    internal let validateStatus: (Int) -> Bool
    
    public var debug = false
    
    public init(
        base: URL? = nil,
        session: URLSession = .shared,
        validateStatus: @escaping (Int) -> Bool = { (200..<300).contains($0) }
    ) {
        self.base = base
        self.session = session
        self.validateStatus = validateStatus
    }
}