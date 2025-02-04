//
//  UnitAngle.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

/// UnitAngle extension of hour angle.
public extension UnitAngle {
    // Hour angle.
    static let hours = UnitAngle(symbol: "h", converter: UnitConverterLinear(coefficient: 15.0))
    
    // milliArcSeconds.
    static let milliArcSeconds = UnitAngle(symbol: "mas", converter: UnitConverterLinear(coefficient: 1.0 / (3600.0 * 1000.0)))
}
