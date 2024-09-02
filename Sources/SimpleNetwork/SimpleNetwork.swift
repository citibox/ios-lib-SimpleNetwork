//
//  SimpleNetwork.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import Foundation

public let version = "0.1.0"

public class SimpleNetwork {
    internal let base: URL
    
    public var debug = false
    
    public init(base: URL) {
        self.base = base
    }
}
