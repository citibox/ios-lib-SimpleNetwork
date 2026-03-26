//
//  SimpleNetwork+DEbug.swift
//
//
//  Created by Marcos Alba on 2/9/24.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.citibox.simplenetwork", category: "network")

internal extension SimpleNetworkManager {
    func log(_ message: String, level: SNLogLevel = .info) {
        guard logLevel != .none, level <= logLevel else { return }
        let levelStr: String
        switch level {
        case .debug: levelStr = "🔍 [debug]"
        case .info:  levelStr = "ℹ️ [info]"
        case .error: levelStr = "❌ [error]"
        case .none:  return
        }
        let formatted = "\(levelStr) 🌐 [network] \(message)"
        switch level {
        case .debug: logger.debug("\(formatted, privacy: .public)")
        case .info:  logger.info("\(formatted, privacy: .public)")
        case .error: logger.error("\(formatted, privacy: .public)")
        case .none:  break
        }
    }
}

// MARK: - Response log helpers

extension SNResponse {
    var logLine: String {
        let resultStr: String
        switch result {
        case .success:            resultStr = "success"
        case .failure(let error): resultStr = "\(error)"
        }
        return "← \(status) \(resultStr) \(url?.absoluteString ?? "")"
    }

    var isSuccess: Bool {
        if case .success = result { return true }
        return false
    }
}
