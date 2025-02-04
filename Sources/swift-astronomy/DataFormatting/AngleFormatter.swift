//
//  AngleFormatter.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2025/01/06.
//

import Foundation

public class AngleFormatter: Formatter {
    public override func string(for obj: Any?) -> String? {
        guard let angle = obj as? Double else { return nil }
        
        let absoluteAngle = abs(angle)
        let degrees = Int(absoluteAngle) * (angle < 0 ? -1 : 1)
        let minutesValue = absoluteAngle.truncatingRemainder(dividingBy: 1.0) * 60.0
        let minutes = Int(minutesValue)
        let secondsValue = minutesValue.truncatingRemainder(dividingBy: 1.0) * 60.0
        let seconds = Int(secondsValue)
        
        return String(format: "%d:%02d:%02d", degrees, minutes, seconds)
    }
    
    public override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        let angleArray = string.split(separator: ":")
        
        var degrees: Double = 0.0
        switch angleArray.count {
        case 3:
            if let seconds = Double(angleArray[2]) {
                degrees = seconds
            } else {
                return false
            }
            fallthrough
        case 2:
            if let minutes = Double(angleArray[1]) {
                degrees = minutes + degrees / 60.0
            } else {
                return false
            }
            fallthrough
        case 1:
            if let degree = Double(angleArray[0]) {
                let sign = degree < 0.0 ? -1.0 : 1.0
                degrees = (abs(degree) + degrees / 60.0) * sign
            } else {
                return false
            }
        default:
            return false
        }
        
        obj?.pointee = degrees as AnyObject
        return true
    }
}
