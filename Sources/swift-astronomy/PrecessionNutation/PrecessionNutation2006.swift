//
//  PrecessionNutation2006.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation
import simd

public struct PrecessionNutation2006: AbstractPrecessionNutation {
    // MARK: - Fundamental Property
    public var date: Date
    public var nutationLuniSolarPlanetary: [Double] = []
    public var nutation: (longitude: Double, obliquity: Double) = (0, 0)
    
    // MARK: - Initializer
    init(date: Date) {
        self.date = date
        
        // Calculate lunisolar nutation and the planetary nutation.
        self.nutationLuniSolarPlanetary = lunisolarPlanetaryNutation()
        
        // Calculate nutation longitude and obliquity.
        self.nutation = nutationSeries()
    }
    
    // MARK: - Protocol Computed Property
    public var meanObliquityOfJ2000: Double {
        Measurement(value: 84381.406, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var lunisolarPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: (5038.481507 + (-1.0790069 + (-0.00114045 + (0.000132851 - 0.0000000951 * t) * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var inclinationOfEquator: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return meanObliquityOfJ2000 + Measurement(value: (-0.025754 + (0.0512623 + (-0.00772503 + (-0.000000467 + 0.0000003337 * t) * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var meanObliquityOfDate: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return meanObliquityOfJ2000 + Measurement(value: (-46.836769 + (-0.0001831 + (0.00200340 + (-0.000000576 - 0.0000000434 * t) * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var planetaryPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: (10.556403 + (-2.3814292 + (-0.00121197 + (0.000170663 - 0.0000000560 * t) * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var equationOfPrecession: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        return Measurement(value: -0.14506 - (4612.156534 + (1.3915817 - 0.00000044 * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    public var equationOfEquinox: Double {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        var ee: Double = 0
        
        for j in 0...1 {
            nonPolynomialSeries[j].forEach({
                var argument: Double = 0
                
                for (index, n) in $0.Delaunay.enumerated() {
                    argument = argument + n * self.nutationLuniSolarPlanetary[index]
                }
                
                let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
                ee = ee + simd_dot($0.C, argumentSinCos) * pow(t, Double(j))
            })
        }
        
        return self.nutation.longitude * cos(self.meanObliquityOfDate) + Measurement(value: ee / 1000000.0, unit: UnitAngle.arcSeconds).converted(to: .radians).value
    }
    
    // MARK: - Protocol Method
    public func nutationSeries() -> (longitude: Double, obliquity: Double) {
        let t = JulianDateConverter(timeScale: .TerrestrialTime).convert(from: self.date).julianCentury
        var nutation: (longitude: Double, obliquity: Double) = (0, 0)
        
        // Calculate nutation of longitude.
        for j in 0...1 {
            longitudeSeries[j].forEach({
                var argument: Double = 0
                
                for (index, n) in $0.Delaunay.enumerated() {
                    argument = argument + n * nutationLuniSolarPlanetary[index]
                }
                
                let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
                nutation.longitude = nutation.longitude + simd_dot($0.A, argumentSinCos) * pow(t, Double(j))
            })
            
            obliquitySeries[j].forEach({
                var argument: Double = 0
                
                for (index, n) in $0.Delaunay.enumerated() {
                    argument = argument * n * nutationLuniSolarPlanetary[index]
                }
                
                let argumentSinCos: vector_double2 = vector_double2(x: sin(argument), y: cos(argument))
                nutation.obliquity = nutation.obliquity + simd_dot($0.B, argumentSinCos) * pow(t, Double(j))
            })
        }
        
        nutation.longitude = Measurement(value: nutation.longitude / 1000000, unit: UnitAngle.arcSeconds).converted(to: .radians).value
        nutation.obliquity = Measurement(value: nutation.obliquity / 1000000, unit: UnitAngle.arcSeconds).converted(to: .radians).value
        
        return nutation
    }
    
}
