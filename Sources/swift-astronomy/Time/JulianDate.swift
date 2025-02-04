//
//  JulianDate.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation

public typealias JulianDate = Double

public extension Date {
    // MARK: - Class Property
    static let JulianDateOfStandardEpoch: Double = 2451545.0        // Julian date of standard epoch(J2000.0)
    static let JulianDateOfReferenceDate: Double = 2451910.5        // Julian date of the Date reference date.
    static let DaysInJulianCentury: Double = 36525.0                // Days in Julian century.
    
    private struct _associatedKeys {
        nonisolated(unsafe) static var key: Int = 0
    }
    
    // MARK: - Initializer
    init(julianDate: Double, timeScale: TimeScale = .CoordinateUniversalTime) {
        self.init(timeIntervalSinceReferenceDate: Measurement(value: julianDate - Self.JulianDateOfReferenceDate, unit: UnitDuration.days).converted(to: .seconds).value)
        self.timeScale = timeScale
    }
    
    init(timeScale: TimeScale) {
        self.init()
        self.timeScale = timeScale
    }
    
    init(date: Date, timeScale: TimeScale = .CoordinateUniversalTime) {
        self.init(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate)
        self.timeScale = timeScale
    }
    
    // MARK: - Computed Property
    var timeScale: TimeScale {
        get {
            guard let value = objc_getAssociatedObject(self, &_associatedKeys.key) as? Int else { return .CoordinateUniversalTime }
            return TimeScale(rawValue: value) ?? .CoordinateUniversalTime
        }
        set {
            objc_setAssociatedObject(self, &_associatedKeys.key, newValue.rawValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// Julian date of date.
    var julianDate: JulianDate {
        Measurement(value: self.timeIntervalSinceReferenceDate, unit: UnitDuration.seconds).converted(to: .days).value + Self.JulianDateOfReferenceDate
    }
    
    /// Julian centuries since the standard epoch.
    var julianCentury: Double {
        (self.julianDate - Self.JulianDateOfStandardEpoch) / Self.DaysInJulianCentury
    }
    
    /// Modified Julian daate.
    var modifiedJulianDate: JulianDate {
        self.julianDate - 2400000.5
    }
}
