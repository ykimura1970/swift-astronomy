//
//  AbstractPrecessionNutation.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

public protocol AbstractPrecessionNutation: Sendable {
    // MARK: - Fundamental Property
    var date: Date { get set }
    var nutationLuniSolarPlanetary: [Double] { get set }
    var nutation: (longitude: Double, obliquity: Double) { get set }
    
    // MARK: - Computed Property
    var meanObliquityOfJ2000: Double { get }
    var lunisolarPrecession: Double { get }             // ψA
    var inclinationOfEquator: Double { get }            // ωA
    var meanObliquityOfDate: Double { get }             // εA
    var trueObliquityOfDate: Double { get }
    var planetaryPrecession: Double { get }             // χA
    var equationOfPrecession: Double { get }
    var equationOfEquinox: Double { get }
    var equationOfOrigins: Double { get }
    
    // MARK: - Fundamental Method
    func lunisolarPlanetaryNutation() -> [Double]
    
    func nutationSeries() -> (longitude: Double, obliquity : Double)
}

// MARK: - Default Implement
public extension AbstractPrecessionNutation {
    var trueObliquityOfDate: Double {
        meanObliquityOfDate + nutation.obliquity
    }
    
    var equationOfOrigins: Double {
        equationOfPrecession - equationOfEquinox
    }
    
    func lunisolarPlanetaryNutation() -> [Double] {
        // The Terrestial time scale in Julian century.
        let t = JulianDateConverter(timeScale: .BarycentricDynamicalTime).convert(from: self.date).julianCentury
        
        // Calculate of lunisoar nutation and the planetary nutation.
        let nutationLunisolarPlanetary = [
            // l = Mean anomaly of the moon.
            Measurement(value: 134.96340251 + Measurement(value: (1717915923.2178 + (318792.0 + (0.051635 - 0.00024470 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .degrees).value, unit: UnitAngle.degrees).converted(to: .radians).value,
            // l' = Mean anomaly of the sun.
            Measurement(value: 357.52910918 + Measurement(value: (129596581.0481 + (-0.5532 + (0.00136 + 0.0001149 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .degrees).value, unit: UnitAngle.degrees).converted(to: .radians).value,
            // F = L - Omega
            Measurement(value: 93.27209062 + Measurement(value: (1739527262.8478 + (-12.7512 + (-0.001037 + 0.00000417 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .degrees).value, unit: UnitAngle.degrees).converted(to: .radians).value,
            // D = Mean elongation of the moon from sun.
            Measurement(value: 297.85019547 + Measurement(value: (1602961601.2090 + (-6.3706 + (0.006593 - 0.00003169 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .degrees).value, unit: UnitAngle.degrees).converted(to: .radians).value,
            // Omega = Mean longitude of the ascending node of the moon.
            Measurement(value: 125.04455501 + Measurement(value: (-6962890.5431 + (7.4722 + (0.007702 - 0.00005939 * t) * t) * t) * t, unit: UnitAngle.arcSeconds).converted(to: .degrees).value, unit: UnitAngle.degrees).converted(to: .radians).value,
            // lMe
            4.402608842 + 2608.7903141574 * t,
            // lVe
            3.176146697 + 1021.3285546211 * t,
            // lE
            1.753470314 + 628.3075849991 * t,
            // lMa
            6.203480913 + 334.0612426700 * t,
            // lJu
            0.599546497 + 52.9690962641 * t,
            // lSa
            0.874016757 + 21.3299104960 * t,
            // lUr
            5.481293872 + 7.4781598567 * t,
            // lNe
            5.311886287 + 3.8133035638 * t,
            // pa
            (0.024381750 + 0.00000538691 * t) * t
        ]
        
        return nutationLunisolarPlanetary
    }
}
