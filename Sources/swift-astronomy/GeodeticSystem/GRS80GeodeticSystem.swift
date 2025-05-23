//
//  GRS80GeodeticSystem.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/18.
//

import Foundation
import CoreLocation

public struct GRS80GeodeticSystem: AbstractGeodeticSystem {
    public static let equatorialRadius: Double = 6378137.0
    public static let aspectRatio: Double = 1.0 / 298.257222101
    public static let geodeticSystemName: String = "GRS80"
    
    public var location: CLLocation
    public var siderealTime: SiderealTime
    
    public init(location: CLLocation, siderealTime: SiderealTime) {
        self.location = location
        self.siderealTime = siderealTime
    }
}
