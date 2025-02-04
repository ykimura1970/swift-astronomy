//
//  JulianDateConverter.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/17.
//

import Foundation


public struct JulianDateConverter {
    // MARK: - Static Property
    static let Lg: Double = 6.969290134e-10
    static let Lb: Double = 1.550519768e-8
    
    // MARK: - Fundamental Property
    public var timeScale: TimeScale
    
    // MARK: - Initializer
    public init(timeScale: TimeScale) {
        self.timeScale = timeScale
    }
    
    // MARK: - Fundamental Method
    public func convert(from date: Date) -> Date {
        switch date.timeScale {
        case .CoordinateUniversalTime:
            return Date(julianDate: convertFromUTC(date: date), timeScale: self.timeScale)
        case .InternationalAtomicTime:
            return Date(julianDate: convertFromTAI(date: date), timeScale: self.timeScale)
        case .TerrestrialTime:
            return Date(julianDate: convertFromTT(date: date), timeScale: self.timeScale)
        case .GeocentricCoordinateTime:
            return Date(julianDate: convertFromTCG(date: date), timeScale: self.timeScale)
        case .BarycentricCoordinateTime:
            return Date(julianDate: convertFromTCB(date: date), timeScale: self.timeScale)
        case .BarycentricDynamicalTime:
            return Date(julianDate: convertFromTDB(date: date), timeScale: self.timeScale)
        }
    }
}

// MARK: - Helper Method
extension JulianDateConverter {
    private func convertFromUTC(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return date.julianDate
        case .InternationalAtomicTime:
            return convertFromUTCToTAI(utcJulianDate: date.julianDate)
        case .TerrestrialTime:
            return convertFromTAIToTT(taiJulianDate: convertFromUTCToTAI(utcJulianDate: date.julianDate))
        case .GeocentricCoordinateTime:
            return convertFromTTToTAI(ttJulianDate: convertFromTAIToTT(taiJulianDate: convertFromUTCToTAI(utcJulianDate: date.julianDate)))
        case .BarycentricCoordinateTime:
            let ttJulianDate = convertFromTAIToTT(taiJulianDate: convertFromUTCToTAI(utcJulianDate: date.julianDate))
            return convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: ttJulianDate), ttJulianDate: ttJulianDate)
        case .BarycentricDynamicalTime:
            let ttJulianDate = convertFromTAIToTT(taiJulianDate: convertFromUTCToTAI(utcJulianDate: date.julianDate))
            return convertFromTCBToTDB(tcbJulianDate: convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: ttJulianDate), ttJulianDate: ttJulianDate))
        }
    }
    
    private func convertFromTAI(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return convertFromTAIToUTC(taiJulianDate: date.julianDate)
        case .InternationalAtomicTime:
            return date.julianDate
        case .TerrestrialTime:
            return convertFromTAIToTT(taiJulianDate: date.julianDate)
        case .GeocentricCoordinateTime:
            return convertFromTTToTCG(ttJulianDate: convertFromTAIToTT(taiJulianDate: date.julianDate))
        case .BarycentricCoordinateTime:
            let ttJulianDate = convertFromTAIToTT(taiJulianDate: date.julianDate)
            return convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: ttJulianDate), ttJulianDate: ttJulianDate)
        case .BarycentricDynamicalTime:
            let ttJulianDate = convertFromTAIToTT(taiJulianDate: date.julianDate)
            return convertFromTCBToTDB(tcbJulianDate: convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: ttJulianDate), ttJulianDate: ttJulianDate))
        }
    }
    
    private func convertFromTT(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return convertFromTAIToUTC(taiJulianDate: convertFromTTToTAI(ttJulianDate: date.julianDate))
        case .InternationalAtomicTime:
            return convertFromTTToTAI(ttJulianDate: date.julianDate)
        case .TerrestrialTime:
            return date.julianDate
        case .GeocentricCoordinateTime:
            return convertFromTTToTCG(ttJulianDate: date.julianDate)
        case .BarycentricCoordinateTime:
            return convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: date.julianDate), ttJulianDate: date.julianDate)
        case .BarycentricDynamicalTime:
            return convertFromTCBToTDB(tcbJulianDate: convertFromTCGtoTCB(tcgJulianDate: convertFromTTToTCG(ttJulianDate: date.julianDate), ttJulianDate: date.julianDate))
        }
    }
    
    private func convertFromTCG(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return convertFromTAIToUTC(taiJulianDate: convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: date.julianDate)))
        case .InternationalAtomicTime:
            return convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: date.julianDate))
        case .TerrestrialTime:
            return convertFromTCGToTT(tcgJulianDate: date.julianDate)
        case .GeocentricCoordinateTime:
            return date.julianDate
        case .BarycentricCoordinateTime:
            return convertFromTCGtoTCB(tcgJulianDate: date.julianDate, ttJulianDate: convertFromTCGToTT(tcgJulianDate: date.julianDate))
        case .BarycentricDynamicalTime:
            return convertFromTCBToTDB(tcbJulianDate: convertFromTCGtoTCB(tcgJulianDate: date.julianDate, ttJulianDate: convertFromTCGToTT(tcgJulianDate: date.julianDate)))
        }
    }
    
    private func convertFromTCB(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return convertFromTAIToUTC(taiJulianDate: convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: date.julianDate))))
        case .InternationalAtomicTime:
            return convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: date.julianDate)))
        case .TerrestrialTime:
            return convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: date.julianDate))
        case .GeocentricCoordinateTime:
            return convertFromTCBtoTCG(tcbJulianDate: date.julianDate)
        case .BarycentricCoordinateTime:
            return date.julianDate
        case .BarycentricDynamicalTime:
            return convertFromTCBToTDB(tcbJulianDate: date.julianDate)
        }
    }
    
    private func convertFromTDB(date: Date) -> JulianDate {
        switch self.timeScale {
        case .CoordinateUniversalTime:
            return convertFromTAIToUTC(taiJulianDate: convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: convertFromTDBToTCB(tdbJulianDate: date.julianDate)))))
        case .InternationalAtomicTime:
            return convertFromTTToTAI(ttJulianDate: convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: convertFromTDBToTCB(tdbJulianDate: date.julianDate))))
        case .TerrestrialTime:
            return convertFromTCGToTT(tcgJulianDate: convertFromTCBtoTCG(tcbJulianDate: convertFromTDBToTCB(tdbJulianDate: date.julianDate)))
        case .GeocentricCoordinateTime:
            return convertFromTCBtoTCG(tcbJulianDate: convertFromTDBToTCB(tdbJulianDate: date.julianDate))
        case .BarycentricCoordinateTime:
            return convertFromTDBToTCB(tdbJulianDate: date.julianDate)
        case .BarycentricDynamicalTime:
            return date.julianDate
        }
    }
}

// MARK: - Convert Method
extension JulianDateConverter {
    private func convertFromUTCToTAI(utcJulianDate: JulianDate) -> JulianDate {
        return utcJulianDate + Measurement(value: deltaAT(utcJulianDate: utcJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
    }
    
    private func convertFromTAIToUTC(taiJulianDate: JulianDate) -> JulianDate {
        // Temporary UTC is obtained by subtracing.
        var tempUTCJulianDate = taiJulianDate - Measurement(value: deltaAT(utcJulianDate: taiJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
        
        // Calculating tru UTC.
        while abs(taiJulianDate - convertFromUTCToTAI(utcJulianDate: tempUTCJulianDate)) > 1.0e-8 {
            tempUTCJulianDate = convertFromUTCToTAI(utcJulianDate: tempUTCJulianDate) - Measurement(value: deltaAT(utcJulianDate: tempUTCJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
        }
        
        return tempUTCJulianDate
    }
    
    private func convertFromTAIToTT(taiJulianDate: JulianDate) -> JulianDate {
        taiJulianDate + Measurement(value: 32.184, unit: UnitDuration.seconds).converted(to: .days).value
    }
    
    private func convertFromTTToTAI(ttJulianDate: JulianDate) -> JulianDate {
        ttJulianDate - Measurement(value: 32.184, unit: UnitDuration.seconds).converted(to: .days).value
    }
    
    private func convertFromTTToTCG(ttJulianDate: JulianDate) -> JulianDate {
        ttJulianDate + Self.Lg * (ttJulianDate - 2443144.5003725)
    }
    
    private func convertFromTCGToTT(tcgJulianDate: JulianDate) -> JulianDate {
        (tcgJulianDate + Self.Lg * 2443144.5003725) / (1.0 + Self.Lg)
    }
    
    private func convertFromTCGtoTCB(tcgJulianDate: JulianDate, ttJulianDate: JulianDate) -> JulianDate {
        tcgJulianDate + Measurement(value: xhf2002(ttJulianDate: ttJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
    }
    
    private func convertFromTCBtoTCG(tcbJulianDate: JulianDate) -> JulianDate {
        var tcgJulianDate = tcbJulianDate - Measurement(value: xhf2002(ttJulianDate: tcbJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
        var ttJulianDate = convertFromTCGToTT(tcgJulianDate: tcgJulianDate)
        var prevTTJulianDate = 0.0
        
        repeat {
            prevTTJulianDate = ttJulianDate
            tcgJulianDate = tcbJulianDate - Measurement(value: xhf2002(ttJulianDate: ttJulianDate), unit: UnitDuration.seconds).converted(to: .days).value
            ttJulianDate = convertFromTCGToTT(tcgJulianDate: tcgJulianDate)
        } while (fabs(prevTTJulianDate - ttJulianDate) > 1.0e-15)
        
        return tcgJulianDate
    }
    
    private func convertFromTCBToTDB(tcbJulianDate: JulianDate) -> JulianDate {
        tcbJulianDate - Self.Lb * (tcbJulianDate - 2443144.5003725) - Measurement(value: 6.55e-5, unit: UnitDuration.seconds).converted(to: .days).value
    }
    
    private func convertFromTDBToTCB(tdbJulianDate: JulianDate) -> JulianDate {
        (tdbJulianDate - Self.Lb * 2443144.5003725 + Measurement(value: 6.55e-5, unit: UnitDuration.seconds).converted(to: .days).value) / (1.0 - Self.Lb)
    }
    
    /// Difference between UTC and TAI.
    /// - Parameters:
    ///  - utcJulianDate: Julian Date in UTC.
    /// - Returns: delta AT.
    private func deltaAT(utcJulianDate: JulianDate) -> Double {
        var dat: Double
        
        // calculating the difference from the Julian dy in UTC.
        switch utcJulianDate {
        case let jd where jd < 2437300.5:
            // before 1961 Jan 1.
            dat = 0.0
        case let jd where jd >= 2437300.5 && jd < 2437512.5:
            // 1961 Jan 1 to 1961 Aug 1.
            dat = 1.422818 + (utcJulianDate - 2437300.5) * 0.001296
        case let jd where jd >= 2437512.5 && jd < 2437665.5:
            dat = 1.372818 + (utcJulianDate - 2437300.5) * 0.001296
        case let jd where jd >= 2437665.5 && jd < 2438334.5:
            dat = 1.845858 + (utcJulianDate - 2437665.5) * 0.0011232
        case let jd where jd >= 2438334.5 && jd < 2438395.5:
            dat = 1.945858 + (utcJulianDate - 2437665.5) * 0.0011232
        case let jd where jd >= 2438395.5 && jd < 2438486.5:
            dat = 3.240130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2438486.5 && jd < 2438608.5:
            dat = 3.340130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2438608.5 && jd < 2438761.5:
            dat = 3.440130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2438761.5 && jd < 2438820.5:
            dat = 3.540130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2438820.5 && jd < 2438942.5:
            dat = 3.640130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2438942.5 && jd < 2439004.5:
            dat = 3.740130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2439004.5 && jd < 2439126.5:
            dat = 3.840130 + (utcJulianDate - 2438761.5) * 0.001296
        case let jd where jd >= 2439126.5 && jd < 2439887.5:
            dat = 4.313170 + (utcJulianDate - 2439126.5) * 0.002592
        case let jd where jd >= 2439887.5 && jd < 2441317.5:
            dat = 4.213170 + (utcJulianDate - 2439126.5) * 0.002592
        case let jd where jd >= 2441317.5 && jd < 2441499.5:
            dat = 10.0
        case let jd where jd >= 2441499.5 && jd < 2441683.5:
            dat = 11.0
        case let jd where jd >= 2441683.5 && jd < 2442048.5:
            dat = 12.0
        case let jd where jd >= 2442048.5 && jd < 2442413.5:
            dat = 13.0
        case let jd where jd >= 2442413.5 && jd < 2442778.5:
            dat = 14.0
        case let jd where jd >= 2442778.5 && jd < 2443144.5:
            dat = 15.0
        case let jd where jd >= 2443144.5 && jd < 2443509.5:
            dat = 16.0
        case let jd where jd >= 2443509.5 && jd < 2443874.5:
            dat = 17.0
        case let jd where jd >= 2443874.5 && jd < 2444239.5:
            dat = 18.0
        case let jd where jd >= 2444239.5 && jd < 2444786.5:
            dat = 19.0
        case let jd where jd >= 2444786.5 && jd < 2445151.5:
            dat = 20.0
        case let jd where jd >= 2445151.5 && jd < 2445516.5:
            dat = 21.0
        case let jd where jd >= 2445516.5 && jd < 2446247.5:
            dat = 22.0
        case let jd where jd >= 2446247.5 && jd < 2447161.5:
            dat = 23.0
        case let jd where jd >= 2447161.5 && jd < 2447892.5:
            dat = 24.0
        case let jd where jd >= 2447892.5 && jd < 2448257.5:
            dat = 25.0
        case let jd where jd >= 2448257.5 && jd < 2448804.5:
            dat = 26.0
        case let jd where jd >= 2448804.5 && jd < 2449169.5:
            dat = 27.0
        case let jd where jd >= 2449169.5 && jd < 2449534.5:
            dat = 28.0
        case let jd where jd >= 2449534.5 && jd < 2450083.5:
            dat = 29.0
        case let jd where jd >= 2450083.5 && jd < 2450630.5:
            dat = 30.0
        case let jd where jd >= 2450630.5 && jd < 2451179.5:
            dat = 31.0
        case let jd where jd >= 2451179.5 && jd < 2453736.5:
            dat = 32.0
        case let jd where jd >= 2453736.5 && jd < 2454832.5:
            dat = 33.0
        case let jd where jd >= 2454832.5 && jd < 2456109.5:
            dat = 34.0
        case let jd where jd >= 2456109.5 && jd < 2457204.5:
            dat = 35.0
        case let jd where jd >= 2457204.5 && jd < 2457754.5:
            dat = 36.0
        case let jd where jd >= 2457754.5:
            dat = 37.0
        default:
            dat = 0
        }
        
        return dat
    }
    
    /// Difference between TCB and TCG.
    /// - Parameters:
    ///  - ttJulianDate: JulianDate of TCG.
    /// - Returns: DIfference between TCB and TCG.
    private func xhf2002(ttJulianDate: JulianDate) -> Double {
        let startJulianDate = 2305450.5
        let HFN1 = 218997.0
        let HFDAT_NE = 463
        let HFDAT_NX = 36
        let dPI2 = 8.0 * atan(1.0)
        let dNd = 4.0 / HFN1
        let t = (ttJulianDate - startJulianDate) - 0.5 * HFN1
        
        let dPI2t = dPI2 * t
        let dXi = dNd * t
        
        let s0 = hf2002data[0].x + (hf2002data[0].y + hf2002data[0].z * dXi) * dXi
        
        var j = HFDAT_NE + HFDAT_NX
        var s1 = 0.0
        for _ in 0..<HFDAT_NX {
            let arg = dPI2t * hf2002data[j].z
            s1 += (dXi * (hf2002data[j].x * sin(arg) + hf2002data[j].y * cos(arg)))
            j -= 1
        }
        
        for _ in 0..<HFDAT_NE {
            let arg = dPI2t * hf2002data[j].z
            s1 += (hf2002data[j].x * sin(arg) + hf2002data[j].y * cos(arg))
            j -= 1
        }
        
        return s1 + s0
    }
}
