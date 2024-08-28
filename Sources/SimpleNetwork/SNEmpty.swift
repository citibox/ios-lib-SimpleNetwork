//
//  SNEmpty.swift
//
//
//  Created by Marcos Alba on 27/8/24.
//

import Foundation

/// Type representing an empty value. Use `SNEmpty.value` to get the static instance.
public struct SNEmpty: Decodable {
    /// Static `SNEmpty` instance used for all `SNEmpty` responses.
    public static let value = SNEmpty()
}
