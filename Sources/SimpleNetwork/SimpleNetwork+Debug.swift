//
//  SimpleNetwork+DEbug.swift
//
//
//  Created by Marcos Alba on 2/9/24.
//

import Foundation

internal extension SimpleNetwork {
    func printDebug(_ text: String) {
        guard debug else { return }
        print(text)
    }
}
