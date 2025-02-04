//
//  SiderealTime.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation
import CoreLocation

public struct SiderealTime: Sendable {
    // MARK: - Fundamental Property
    var date: Date
    var precessionNutation: any AbstractPrecessionNutation
    var location: CLLocation
    var earthRotationAngle: Double
    
    // MARK: - Initializer
    public init(date: Date, location: CLLocation, model: PrecessionNutationModel) {
        switch model {
        case .IAU2006:
            self.init(date: date, location: location, precessionNutation: PrecessionNutation2006(date: date))
        case .IAU2000A:
            self.init(date: date, location: location, precessionNutation: PrecessionNutation2000A(date: date))
        }
    }
    
    public init(date: Date = Date(), location: CLLocation, precessionNutation: any AbstractPrecessionNutation) {
        self.date = date
        self.location = location
        self.precessionNutation = precessionNutation
        
        // Calculate earth rotation angle for the specified date.
        let tu = JulianDateConverter(timeScale: .CoordinateUniversalTime).convert(from: self.date).julianDate - Date.JulianDateOfStandardEpoch
        self.earthRotationAngle = Measurement(value: Measurement(value: 0.7790572732640 + 1.00273781191135448 * tu, unit: UnitAngle.revolutions).value.truncatingRemainder(dividingBy: 1), unit: UnitAngle.revolutions).converted(to: .radians).value
    }
    
    // MARK: - Computed Property
    public var greenwitchMeanSiderealTime: Double {
        Measurement(value: Measurement(value: self.earthRotationAngle - self.precessionNutation.equationOfPrecession, unit: UnitAngle.radians).converted(to: .revolutions).value.truncatingRemainder(dividingBy: 1), unit: UnitAngle.revolutions).converted(to: .radians).value
    }
    
    public var greenwitchApparentSiderealTime: Double {
        Measurement(value: Measurement(value: self.earthRotationAngle - self.precessionNutation.equationOfOrigins, unit: UnitAngle.radians).converted(to: .revolutions).value.truncatingRemainder(dividingBy: 1), unit: UnitAngle.revolutions).converted(to: .radians).value
    }
    
    public var localMeanSiderealTime: Double {
        Measurement(value: Measurement(value: greenwitchMeanSiderealTime + Measurement(value: self.location.coordinate.longitude, unit: UnitAngle.degrees).converted(to: .radians).value, unit: UnitAngle.radians).converted(to: .revolutions).value.truncatingRemainder(dividingBy: 1), unit: UnitAngle.revolutions).converted(to: .radians).value
    }
    
    public var localApparentSiderealTime: Double {
        Measurement(value: Measurement(value: greenwitchApparentSiderealTime + Measurement(value: self.location.coordinate.longitude, unit: UnitAngle.degrees).converted(to: .radians).value, unit: UnitAngle.radians).converted(to: .revolutions).value.truncatingRemainder(dividingBy: 1), unit: UnitAngle.revolutions).converted(to: .radians).value
    }
}
