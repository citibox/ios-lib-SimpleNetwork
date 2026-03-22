//
//  SimpleNetwork+DEbug.swift
//
//
//  Created by Marcos Alba on 2/9/24.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "com.citibox.simplenetwork", category: "HTTP")

internal extension SimpleNetworkManager {
    func log(_ message: String, level: SNLogLevel = .info) {
        guard logLevel != .none, level <= logLevel else { return }
        switch level {
        case .debug: logger.debug("\(message, privacy: .public)")
        case .info:  logger.info("\(message, privacy: .public)")
        case .error: logger.error("\(message, privacy: .public)")
        case .none:  break
        }
    }
}
