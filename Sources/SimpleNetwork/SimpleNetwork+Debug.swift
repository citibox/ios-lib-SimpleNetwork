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
    func printDebug(_ text: String) {
        guard debug else { return }
        logger.debug("\(text, privacy: .public)")
    }

    func printError(_ text: String) {
        logger.error("\(text, privacy: .public)")
    }
}
