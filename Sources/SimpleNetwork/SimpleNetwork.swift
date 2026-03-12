//
//  SimpleNetwork.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import Foundation

public let version = "0.1.0"

/// Main network client
public class SimpleNetworkManager {
    internal let base: URL?
    
    public var debug = false
    
    public init(base: URL? = nil) {
        self.base = base
    }
}