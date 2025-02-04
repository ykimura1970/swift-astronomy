//
//  RightascensionFormat.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/01/06.
//

import Foundation

public struct RightascensionFormat: FormatStyle {
    public typealias FormatInput = Double
    public typealias FormatOutput = String
    
    public let fractionLength: Int
    
    public func format(_ value: FormatInput) -> FormatOutput {
        let hours = Int(value)
        let minutesValue = value.truncatingRemainder(dividingBy: 1.0) * 60.0
        let minutes = Int(minutesValue)
        let secondsValue = minutesValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let seconds = Int(secondsValue)
        
        var formattedValue: String = String(format: "%02dh", hours)
        
        switch fractionLength {
        case 3:
            formattedValue = formattedValue + String(format: "%02dm", minutes)
        case 5:
            formattedValue = formattedValue + String(format: "%04.1fm", minutesValue)
        case 6:
            formattedValue = formattedValue + String(format: "%02dm", minutes) + String(format: "%02ds", seconds)
        case 8:
            formattedValue = formattedValue + String(format: "%02dm", minutes) + String(format: "%04.1fs", secondsValue)
        case 9:
            formattedValue = formattedValue + String(format: "%02dm", minutes) + String(format: "%05.2fs", secondsValue)
        default:
            formattedValue = String(format: "%.6fh", value)
        }
        
        return formattedValue
    }
}

public extension FormatStyle where Self == RightascensionFormat {
    static func rightascension(fractionLength: Int) -> RightascensionFormat {
        .init(fractionLength: fractionLength)
    }
}
