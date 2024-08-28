//
//  SNError.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import Foundation

public enum SNError: Error {
    case unknown
    case connectionLost
    case timeout
    case noInternet
    case cannotDecode
}
