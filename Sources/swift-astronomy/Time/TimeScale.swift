//
//  TimeScale.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

/// Definition of time scale.
public enum TimeScale: Int, Codable {
    case CoordinateUniversalTime = 0
    case InternationalAtomicTime = 1
    case TerrestrialTime = 2
    case GeocentricCoordinateTime = 3
    case BarycentricCoordinateTime = 4
    case BarycentricDynamicalTime = 5
    
    public func toString() -> String {
        switch self {
        case .CoordinateUniversalTime: return "UTC"
        case .InternationalAtomicTime: return "TAI"
        case .TerrestrialTime: return "TT"
        case .GeocentricCoordinateTime: return "TCG"
        case .BarycentricCoordinateTime: return "TCB"
        case .BarycentricDynamicalTime: return "TDB"
        }
    }
}
