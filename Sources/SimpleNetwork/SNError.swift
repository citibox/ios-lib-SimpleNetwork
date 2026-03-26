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
    case invalidStatus(Int)
    case encodingFailed
    case invalidURL
    case invalidRetryDelay
}

extension SNError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:              return "unknown error"
        case .connectionLost:       return "connection lost"
        case .timeout:              return "timeout"
        case .noInternet:           return "no internet"
        case .cannotDecode:         return "cannot decode response"
        case .invalidStatus(let c): return "HTTP \(c)"
        case .encodingFailed:       return "encoding failed"
        case .invalidURL:           return "invalid URL"
        case .invalidRetryDelay:    return "invalid retry delay"
        }
    }
}
