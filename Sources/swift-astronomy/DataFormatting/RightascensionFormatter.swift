//
//  RightascensionFormatter.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/01/06.
//

import Foundation

public class RightascensionFormatter: Formatter {
    public override func string(for obj: Any?) -> String? {
        guard let angle = obj as? Double else { return nil }
        
        let hours = Int(angle)
        let minutesValue = angle.truncatingRemainder(dividingBy: 1.0) * 60.0
        let minutes = Int(minutesValue)
        let secondsValue = minutesValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let seconds = Int(secondsValue)
        
        return String(format: "%02dh%02dm%02ds", hours, minutes, seconds)
    }
    
    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let angleArray = string.split(whereSeparator: { $0 == "h" || $0 == "m" || $0 == "s" })
        var hourAngle: Double = 0.0
        
        switch angleArray.count {
        case 3:
            if let seconds = Double(angleArray[2]) {
                hourAngle = seconds
            } else {
                return false
            }
            fallthrough
        case 2:
            if let minutes = Double(angleArray[1]) {
                hourAngle = minutes + hourAngle / 60.0
            } else {
                return false
            }
            fallthrough
        case 1:
            if let hours = Double(angleArray[0]) {
                hourAngle = hours + hourAngle / 60.0
            } else {
                return false
            }
        default:
            return false
        }
        
        obj?.pointee = hourAngle as AnyObject
        return true
    }
}
