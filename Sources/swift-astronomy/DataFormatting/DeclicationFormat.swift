//
//  DeclinationFormat.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/01/06.
//

import Foundation

public struct DeclinationFormat: FormatStyle {
    public typealias FormatInput = Double
    public typealias FormatOutput = String
    
    public let fractionLength: Int
    
    public func format(_ value: FormatInput) -> FormatOutput {
        let sign = value < 0 ? "-" : "+"
        let absoluteValue = abs(value)
        let degrees = Int(absoluteValue)
        let minutesValue = absoluteValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let minutes = Int(minutesValue)
        let secondsValue = minutesValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let seconds = Int(secondsValue)
        
        var formattedValue: String = String(format: "%@%02d:", sign, degrees)
        
        switch fractionLength {
        case 3:
            formattedValue = formattedValue + String(format: "%02d", minutes)
        case 5:
            formattedValue = formattedValue + String(format: "%04.1f", minutesValue)
        case 6:
            formattedValue = formattedValue + String(format: "%02d:", minutes) + String(format: "%02d", seconds)
        case 8:
            formattedValue = formattedValue + String(format: "%02d:", minutes) + String(format: "%04.1f", secondsValue)
        case 9:
            formattedValue = formattedValue + String(format: "%02d:", minutes) + String(format: "%05.2f", secondsValue)
        default:
            formattedValue = String(format: "%.6f", value)
        }
        
        return formattedValue
    }
}

public extension FormatStyle where Self == DeclinationFormat {
    static func declination(fractionLength: Int) -> DeclinationFormat {
        .init(fractionLength: fractionLength)
    }
}
