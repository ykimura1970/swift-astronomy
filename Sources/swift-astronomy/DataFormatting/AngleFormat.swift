//
//  AngleFormat.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

public struct AngleFormat: FormatStyle {
    public typealias FormatInput = Double
    public typealias FormatOutput = String
    
    public let fractionLength: Int
    
    public func format(_ value: FormatInput) -> FormatOutput {
        let sign = value < 0 ? -1 : 1
        let absoluteValue = abs(value)
        let degrees = Int(absoluteValue) * sign
        let minutesValue = absoluteValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let minutes = Int(minutesValue)
        let secondsValue = minutesValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let seconds = Int(secondsValue)
        
        var formattedValue: String = "\(degrees.formatted()):"
        
        switch fractionLength {
        case 3:
            formattedValue = formattedValue + String(format: "%02d", minutes)
        case 5:
            formattedValue = formattedValue + String(format: "%4.1f", minutesValue)
        case 6:
            formattedValue = formattedValue + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        case 8:
            formattedValue = formattedValue + String(format: "%02d", minutes) + ":" + String(format: "%4.1f", secondsValue)
        case 9:
            formattedValue = formattedValue + String(format: "%02d", minutes) + ":" + String(format: "%5.2f", secondsValue)
        default:
            formattedValue = String(format: "%.6f", value)
        }
        
        return formattedValue
    }
}

public extension FormatStyle where Self == AngleFormat {
    static func angle(fractionLength: Int) -> AngleFormat {
        .init(fractionLength: fractionLength)
    }
}
