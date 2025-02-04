//
//  PrecessionNutation2000A.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation
import simd

public struct PrecessionNutation2000A: AbstractPrecessionNutation {
    // MARK: - Fundamental Property
    public var date: Date
    public var nutationLuniSolarPlanetary: [Double] = []
    public var nutation: (longitude: Double, obliquity: Double) = (0, 0)
    
    // MARK: - Initializer
    init(date: Date) {
        self.date = date
        
        // Calculate lunisolar nutation and the planetary nutation.
        self.nutationLuniSolarPlanetary = lunisolarPlanetaryNutation()
        
        // calculate nutation longitude and obliquity.
        self.nutation = nutationSeries()
    }
    
    // MARK: - Protocol Computed Property
    public var meanObliquityOfJ2000: Double {
        Measurement(value: 84381.448, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var lunisolarPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: (5038.47875 + (-1.07259 - 0.001147 * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var inclinationOfEquator: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: (-0.02524 + (0.05127 + 0.007726 * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var meanObliquityOfDate: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return meanObliquityOfJ2000 + Measurement(value: (-46.84024 + (-0.00059 + 0.001813 * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var planetaryPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: (10.5526 + (-2.38064 - 0.001125 * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var equationOfPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: -0.014506 - (4612.15739966 + (1.39667721 + (-0.00009344 + 0.00001882 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var equationOfEquinox: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        var ee: Double = 0
        
        for j in 0...4 {
            nonPolynomialSeries2000A[j].forEach({
                var argument: Double = 0
                
                for (index, n) in $0.Delaunay.enumerated() {
                    argument = argument + n * nutationLuniSolarPlanetary[index]
                }
                
                let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
                ee = ee + simd_dot($0.C, argumentSinCos) * pow(t, Double(j))
            })
        }
        
        ee = ee / 1000000.0 + 0.00000087 * t * sin(nutationLuniSolarPlanetary[5])
        return nutation.longitude * cos(meanObliquityOfDate) - Measurement(value: ee, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }

    // MARK: - Protocol Method
    public func nutationSeries() -> (longitude: Double, obliquity: Double) {
        var nutation: (longitude: Double, obliquity: Double) = (0, 0)
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        let timeVector = vector_double2(x: t, y: t)
        
        // Calculate lunisolar nutation.
        lunisolarSeries2000A.forEach({
            var argument: Double = 0
            
            for (index, n) in $0.Delaunay.enumerated() {
                argument = argument + n * nutationLuniSolarPlanetary[index]
            }
            
            let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
            
            nutation.longitude = Measurement(value: nutation.longitude + simd_dot(_simd_fma_d2($0.At, timeVector, $0.A), argumentSinCos), unit: UnitAngle.arcSeconds).converted(to: .radians).value
            nutation.obliquity = Measurement(value: nutation.obliquity + simd_dot(_simd_fma_d2($0.Bt, timeVector, $0.B), argumentSinCos), unit: UnitAngle.arcSeconds).converted(to: .radians).value
        })
        
        // Calculate planetary nutation.
        planetarySeries2000A.forEach({
            var argument: Double = 0
            
            for (index, n) in $0.Delaunay.enumerated() {
                argument = argument + n * nutationLuniSolarPlanetary[index]
            }
            
            let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
            
            nutation.longitude = nutation.longitude + simd_dot($0.A, argumentSinCos)
            nutation.obliquity = nutation.obliquity + simd_dot($0.B, argumentSinCos)
        })
        
        nutation.longitude = Measurement(value: nutation.longitude, unit: UnitAngle.milliArcSeconds).converted(to: .radians).value
        nutation.obliquity = Measurement(value: nutation.obliquity, unit: UnitAngle.milliArcSeconds).converted(to: .radians).value
        
        return nutation
    }
}
