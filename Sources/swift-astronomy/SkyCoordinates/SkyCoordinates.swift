//
//  SkyCoordinates.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/18.
//

import Foundation
import simd

public struct SkyCoordinates: Hashable, Sendable {
    // MARK: - Fundamental Property
    public var celestial: vector_double3 = .zero
    public var cartesian: vector_double3 = .zero
    public var coordinatesSystem: SkyCoordinatesSystem
    
    // MARK: - Initializer
    public init(celestial: vector_double3, coordinatesSystem: SkyCoordinatesSystem) {
        self.coordinatesSystem = coordinatesSystem
        self.celestial = celestial
        self.cartesian = convertCelectialToCartesian(celestial: celestial)
    }
    
    public init(cartesian: vector_double3, coordinatesSystem: SkyCoordinatesSystem) {
        self.coordinatesSystem = coordinatesSystem
        self.cartesian = cartesian
        self.celestial = convertCartesianToCelectial(cartesian: cartesian)
    }
    
    public init(longitudeInHours longitude: Double, latitudeInDegrees latitude: Double, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(celestial: vector_double3(x: Measurement(value: longitude, unit: UnitAngle.hours).converted(to: .radians).value, y: Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value, z: 1.0), coordinatesSystem: coordinatesSystem)
    }
    
    public init(longitudeInDegrees longitude: Double, latitudeInDegrees latitude: Double, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(celestial: vector_double3(x: Measurement(value: longitude, unit: UnitAngle.degrees).converted(to: .radians).value, y: Measurement(value: latitude, unit: UnitAngle.degrees).converted(to: .radians).value, z: 1.0), coordinatesSystem: coordinatesSystem)
    }
    
    public init(longitudeInRadians longitude: Double, latitudeInRadians latitude: Double, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(celestial: vector_double3(x: longitude, y: latitude, z: 1.0), coordinatesSystem: coordinatesSystem)
    }
    
    public init(vector2DInDegrees celestial2D: vector_double2, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(celestial: vector_double3(vector_double2(x: Measurement(value: celestial2D.x, unit: UnitAngle.degrees).converted(to: .radians).value, y: Measurement(value: celestial2D.y, unit: UnitAngle.degrees).converted(to: .radians).value), 1.0), coordinatesSystem: coordinatesSystem)
    }
    
    public init(vector2DInRadians celestial2D: vector_double2, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(celestial: vector_double3(celestial2D, 1.0), coordinatesSystem: coordinatesSystem)
    }
    
    public init(x: Double, y: Double, z: Double, coordinatesSystem: SkyCoordinatesSystem) {
        self.init(cartesian: vector_double3(x: x, y: y, z: z), coordinatesSystem: coordinatesSystem)
    }
    
    // MARK: - Computed Property
    public var vectorCelestialCoordinates: vector_double2 {
        vector_double2(x: self.celestial.x, y: self.celestial.y)
    }
    
    public var vectorCelestialCoordinatesInDegrees: vector_double2 {
        vector_double2(x: Measurement(value: celestial.x, unit: UnitAngle.radians).converted(to: .degrees).value, y: Measurement(value: celestial.y, unit: UnitAngle.radians).converted(to: .degrees).value)
    }
    
    public var vectorCelestialCoorinatesInEquator: vector_double2 {
        vector_double2(x: Measurement(value: celestial.x, unit: UnitAngle.radians).converted(to: .hours).value, y: Measurement(value: celestial.y, unit: UnitAngle.radians).converted(to: .degrees).value)
    }
    
    public var normalizeCartesianCoordinates: vector_double3 {
        simd_normalize(self.cartesian)
    }
}

// MARK: - Helper Method
extension SkyCoordinates {
    private func convertCelectialToCartesian(celestial: vector_double3) -> vector_double3 {
        let s1 = sin(celestial.x)
        let c1 = cos(celestial.x)
        let s2 = sin(celestial.y)
        let c2 = cos(celestial.y)
        
        return vector_double3(x: c2 * c1, y: c2 * s1, z: s2) * celestial.z
    }
    
    private func convertCartesianToCelectial(cartesian: vector_double3) -> vector_double3 {
        var longitude = atan2(cartesian.y, cartesian.x)
        longitude = longitude < 0 ? longitude + 2 * .pi : longitude
        
        let latitude = atan(cartesian.z / sqrt(cartesian.x * cartesian.x + cartesian.y * cartesian.y))
        
        return vector_double3(x: longitude, y: latitude, z: simd_length(cartesian))
    }
}
