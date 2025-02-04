//
//  UnitDuration.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

/// UnitDuration extension of seconds in day.
public extension UnitDuration {
    // seconds in day.
    static let days = UnitDuration(symbol: "day", converter: UnitConverterLinear(coefficient: 24.0 * 3600.0))
}
