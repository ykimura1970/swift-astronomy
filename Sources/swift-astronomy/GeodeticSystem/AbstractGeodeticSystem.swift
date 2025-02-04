//
//  AbstractGeodeticSystem.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/18.
//

import Foundation
import CoreLocation
import simd

public protocol AbstractGeodeticSystem: Sendable {
    // MARK: - Static Property
    static var equatorialRadius: Double { get }
    static var aspectRatio: Double { get }
    static var geodeticSystemName: String { get }
    
    // MARK: - Fundamental Property
    var location: CLLocation { get set }
    var siderealTime: SiderealTime { get set }
    
    // MARK: - Computed Property
    var siteMeanCartesianCoordinates: vector_double3 { get }
    
    var siteApparentCartesianCoordinates: vector_double3 { get }
    
    var siteCartesianCoordinates: vector_double3 { get }
    
    func matrixGMSTRotation() -> matrix_double3x3
    
    func matrixGASTRotation() -> matrix_double3x3
}

public extension AbstractGeodeticSystem {
    var siteMeanCartesianCoordinates: vector_double3 {
        matrixGMSTRotation() * siteCartesianCoordinates
    }
    
    var siteApparentCartesianCoordinates: vector_double3 {
        matrixGASTRotation() * siteCartesianCoordinates
    }
    
    var siteCartesianCoordinates: vector_double3 {
        let sinLongitude = sin(Measurement(value: self.location.coordinate.longitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        let cosLongitude = cos(Measurement(value: self.location.coordinate.latitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        let sinLatitude = sin(Measurement(value: self.location.coordinate.latitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        let cosLatitude = cos(Measurement(value: self.location.coordinate.latitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        
        let eccentricitySquared = Self.aspectRatio * (2.0 - Self.aspectRatio)
        let radiusOfCurvature = Self.equatorialRadius / sqrt(1.0 - eccentricitySquared * sinLatitude * sinLatitude)
        
        let x = (radiusOfCurvature + location.altitude) / 1000.0 * cosLatitude * cosLongitude
        let y = (radiusOfCurvature + location.altitude) / 1000.0 * cosLatitude * sinLongitude
        let z = (radiusOfCurvature * (1.0 - eccentricitySquared) + location.altitude) / 1000.0 * sinLatitude
        
        return vector_double3(x: x, y: y, z: z)
    }
    
    func matrixGMSTRotation() -> matrix_double3x3 {
        let sinGMST = sin(-siderealTime.greenwitchMeanSiderealTime)
        let cosGMST = cos(-siderealTime.greenwitchMeanSiderealTime)
        
        let row1 = vector_double3(x: cosGMST, y: sinGMST, z: 0.0)
        let row2 = vector_double3(x: -sinGMST, y: cosGMST, z: 0.0)
        let row3 = vector_double3(x: 0.0, y: 0.0, z: 1.0)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    func matrixGASTRotation() -> matrix_double3x3 {
        let sinGAST = sin(-siderealTime.greenwitchMeanSiderealTime)
        let cosGAST = cos(-siderealTime.greenwitchMeanSiderealTime)
        
        let row1 = vector_double3(x: cosGAST, y: sinGAST, z: 0.0)
        let row2 = vector_double3(x: -sinGAST, y: cosGAST, z: 0.0)
        let row3 = vector_double3(x: 0.0, y: 0.0, z: 1.0)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
}
