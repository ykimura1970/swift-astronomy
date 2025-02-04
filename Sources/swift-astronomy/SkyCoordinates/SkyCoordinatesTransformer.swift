//
//  SkyCoordinatesTransformer.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/18.
//

import Foundation
import CoreLocation
import simd

public struct SkyCoordinatesTransformer {
    // MARK: - Static Property
    public static let offsetOfICRSRightAscensionOffset: Double = Measurement(value: -14.6, unit: UnitAngle.milliArcSeconds).converted(to: .radians).value
    public static let celestialPoleOffsetOf12Hour: Double = Measurement(value: 9.1, unit: UnitAngle.milliArcSeconds).converted(to: .radians).value
    public static let celestialPoleOffsetOf18Hour: Double = Measurement(value: -19.9, unit: UnitAngle.milliArcSeconds).converted(to: .radians).value
    
    // MARK: - Fundamental Property
    public var date: Date
    public var precessionNutaion: any AbstractPrecessionNutation
    
    // MARK: - Initializer
    public init(date: Date, model: PrecessionNutationModel) {
        switch model {
        case .IAU2000A:
            self.init(date: date, precessionNutation: PrecessionNutation2000A(date: date))
        case .IAU2006:
            self.init(date: date, precessionNutation: PrecessionNutation2006(date: date))
        }
    }
    
    public init(date: Date, precessionNutation: any AbstractPrecessionNutation) {
        self.date = date
        self.precessionNutaion = precessionNutation
    }
    
    // MARK: - Fundamental Method
    public func transform(from coordinates: SkyCoordinates, toCoordinatesSystem coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinates.coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return transformFromICRS(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EquatorialCoordinatesMeanOfJ2000:
            return transformFromEquatorialMeanOfJ2000(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EquatorialCoordinatesMeanOfDate:
            return transformFromEquatorialMeanOfDate(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EquatorialCoordinatesTrueOfDate:
            return transformFromEquatorialTrueOfDate(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EclipticCoordinatesMeanOfJ2000:
            return transformFromEclipticMeanOfJ2000(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EclipticCoordinatesMeanOfDate:
            return transformFromEclipticMeanOfDate(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .EclipticCoordinatesTrueOfDate:
            return transformFromEclipticTrueOfDate(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .GalacticCoordinates:
            return transformFromGalactic(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        case .HorizontalCoordinates:
            return transformFromHorizontal(coordinates: coordinates, coordinatesSystem: coordinatesSystem, location: location)
        }
    }
}

// MARK: - Coordinates Transform Helper Method
extension SkyCoordinatesTransformer {
    private func transformFromICRS(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return coordinates
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEquatorialMeanOfJ2000(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return coordinates
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEquatorialMeanOfDate(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return coordinates
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: coordinates.cartesian, location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEquatorialTrueOfDate(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return coordinates
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEclipticMeanOfJ2000(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return coordinates
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEclipticMeanOfDate(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return coordinates
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromEclipticTrueOfDate(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return coordinates
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: coordinates.cartesian)), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromGalactic(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return coordinates
        case .HorizontalCoordinates:
            guard let loc = location else { return nil }
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: coordinates.cartesian)), location: loc), coordinatesSystem: coordinatesSystem)
        }
    }
    
    private func transformFromHorizontal(coordinates: SkyCoordinates, coordinatesSystem: SkyCoordinatesSystem, location: CLLocation? = nil) -> SkyCoordinates? {
        guard let loc = location else { return nil }
        
        switch coordinatesSystem {
        case .InternationalCelestialReferenceSystem:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc))), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc)), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc), coordinatesSystem: coordinatesSystem)
        case .EquatorialCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfJ2000:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc))), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesMeanOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc)), coordinatesSystem: coordinatesSystem)
        case .EclipticCoordinatesTrueOfDate:
            return SkyCoordinates(cartesian: transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc))), coordinatesSystem: coordinatesSystem)
        case .GalacticCoordinates:
            return SkyCoordinates(cartesian: transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: coordinates.cartesian, location: loc))), coordinatesSystem: coordinatesSystem)
        case .HorizontalCoordinates:
            return coordinates
        }
    }
}

// MARK: - Cartesian Coordinates Transform Method
extension SkyCoordinatesTransformer {
    private func transformFromICRSToEquatorialMeanOfJ2000(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixFrameBias = makeFrameBiasMatrixBySecondOrder()
        return matrixFrameBias * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfJ2000ToICRS(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseFrameBias = makeFrameBiasMatrixBySecondOrder().inverse
        return matrixInverseFrameBias * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfJ2000ToEquatorialMeanOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixPrecession = makePrecessionMatrix()
        return matrixPrecession * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfDateToEquatorialMeanOfJ2000(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInversePrecession = makePrecessionMatrix().inverse
        return matrixInversePrecession * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfDateToEquatorialTrueOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixNutation = makeNutationMatrix()
        return matrixNutation * cartesianCoordinates
    }

    private func transformFromEquatorialTrueOfDateToEquatorialMeanOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseNutation = makeNutationMatrix().inverse
        return matrixInverseNutation * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfJ2000ToEclipticMeanOfJ2000(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixRotation = makeJ2000ObliquityRotationMatrix()
        return matrixRotation * cartesianCoordinates
    }
    
    private func transformFromEclipticMeanOfJ2000ToEquatorialMeanOfJ2000(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseRotation = makeJ2000ObliquityRotationMatrix().inverse
        return matrixInverseRotation * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfDateToEclipticMeanOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixRotation = makeMeanObliquityRotationMatrix()
        return matrixRotation * cartesianCoordinates
    }
    
    private func transformFromEclipticMeanOfDateToEquatorialMeanOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseRotation = makeMeanObliquityRotationMatrix().inverse
        return matrixInverseRotation * cartesianCoordinates
    }
    
    private func transformFromEquatorialTrueOfDateToEclipticTrueOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixRotation = makeTrueObliquityRotationMatrix()
        return matrixRotation * cartesianCoordinates
    }
    
    private func transformFromEclipticTrueOfDateToEquatorialTrueOfDate(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseRotation = makeTrueObliquityRotationMatrix().inverse
        return matrixInverseRotation * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfJ2000ToGalactic(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixRotation = makeGalacticCoordinatesRotationMatrix()
        return matrixRotation * cartesianCoordinates
    }
    
    private func transformFromGalacticToEquatorialMeanOfJ2000(cartesianCoordinates: vector_double3) -> vector_double3 {
        let matrixInverseRotation = makeGalacticCoordinatesRotationMatrix().inverse
        return matrixInverseRotation * cartesianCoordinates
    }
    
    private func transformFromEquatorialMeanOfDateToHorizontal(cartesianCoordinates: vector_double3, location: CLLocation) -> vector_double3 {
        let matrixHorizontal = makeHorizontalMatrix(location: location)
        return matrixHorizontal * cartesianCoordinates
    }
    
    private func transformFromHorizontalToEquatorialMeanOfDate(cartesianCoordinates: vector_double3, location: CLLocation) -> vector_double3 {
        let matrixInverseHorizontal = makeHorizontalMatrix(location: location).inverse
        return matrixInverseHorizontal * cartesianCoordinates
    }
}

// MARK: - Transform Matrix Method
extension SkyCoordinatesTransformer {
    private func makeFrameBiasMatrixByFirstOrder() -> matrix_double3x3 {
        let row1 = vector_double3(x: 1.0, y: Self.offsetOfICRSRightAscensionOffset, z: -Self.celestialPoleOffsetOf12Hour)
        let row2 = vector_double3(x: -Self.offsetOfICRSRightAscensionOffset, y: 1.0, z: -Self.celestialPoleOffsetOf18Hour)
        let row3 = vector_double3(x: Self.celestialPoleOffsetOf12Hour, y: Self.celestialPoleOffsetOf18Hour, z: 1.0)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeFrameBiasMatrixBySecondOrder() -> matrix_double3x3 {
        let squareOffsetOfICRSRightAscensionOffset = Self.offsetOfICRSRightAscensionOffset * Self.offsetOfICRSRightAscensionOffset
        let squareCelestialPoleOffsetOf12Hour = Self.celestialPoleOffsetOf12Hour * Self.celestialPoleOffsetOf12Hour
        let squareCelestialPoleOffsetOf18Hour = Self.celestialPoleOffsetOf18Hour * Self.celestialPoleOffsetOf18Hour
        
        let row1 = vector_double3(x: 1.0 - (squareOffsetOfICRSRightAscensionOffset + squareCelestialPoleOffsetOf12Hour) * 0.5, y: Self.offsetOfICRSRightAscensionOffset, z: -Self.celestialPoleOffsetOf12Hour)
        let row2 = vector_double3(x: -(Self.offsetOfICRSRightAscensionOffset + Self.celestialPoleOffsetOf18Hour * Self.celestialPoleOffsetOf12Hour), y: 1.0 - (squareOffsetOfICRSRightAscensionOffset + squareCelestialPoleOffsetOf18Hour) * 0.5, z: -Self.celestialPoleOffsetOf18Hour)
        let row3 = vector_double3(x: Self.celestialPoleOffsetOf12Hour - Self.celestialPoleOffsetOf18Hour * Self.offsetOfICRSRightAscensionOffset, y: Self.celestialPoleOffsetOf18Hour + Self.celestialPoleOffsetOf12Hour * Self.offsetOfICRSRightAscensionOffset, z: 1.0 - (squareCelestialPoleOffsetOf18Hour + squareCelestialPoleOffsetOf12Hour) * 0.5)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makePrecessionMatrix() -> matrix_double3x3 {
        let s1 = sin(self.precessionNutaion.meanObliquityOfJ2000)
        let s2 = sin(-self.precessionNutaion.lunisolarPrecession)
        let s3 = sin(-self.precessionNutaion.inclinationOfEquator)
        let s4 = sin(self.precessionNutaion.planetaryPrecession)
        let c1 = cos(self.precessionNutaion.meanObliquityOfJ2000)
        let c2 = cos(-self.precessionNutaion.lunisolarPrecession)
        let c3 = cos(-self.precessionNutaion.inclinationOfEquator)
        let c4 = cos(self.precessionNutaion.planetaryPrecession)
        
        let row1 = vector_double3(x: c4 * c2 - s2 * s4 * c3, y: c4 * s2 * c1 + s4 * c3 * c2 * c1 - s1 * s4 * s3, z: c4 * s2 * s1 + s4 * c3 * c2 * s1 + c1 * s4 * s3)
        let row2 = vector_double3(x: -s4 * c2 - s2 * c4 * c3, y: -s4 * s2 * c1 + c4 * c3 * c2 * c1 - s1 * c4 * s3, z: -s4 * s2 * s1 + c4 * c3 * c2 * s1 + c1 * c4 * s3)
        let row3 = vector_double3(x: s2 * s3, y: -s3 * c2 * c1 - s1 * c3, z: -s3 * c2 * s1 + c3 * c1)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeNutationMatrix() -> matrix_double3x3 {
        let s1 = sin(self.precessionNutaion.meanObliquityOfDate)
        let s2 = sin(-self.precessionNutaion.nutation.longitude)
        let s3 = sin(-self.precessionNutaion.meanObliquityOfDate - self.precessionNutaion.nutation.obliquity)
        let c1 = cos(self.precessionNutaion.meanObliquityOfDate)
        let c2 = cos(-self.precessionNutaion.nutation.longitude)
        let c3 = cos(-self.precessionNutaion.meanObliquityOfDate - self.precessionNutaion.nutation.obliquity)
        
        let row1 = vector_double3(x: c2, y: s2 * c1, z: s2 * s1)
        let row2 = vector_double3(x: -s2 * c3, y: c3 * c2 * c1 - s1 * s3, z: c3 * c2 * s1 + c1 * s3)
        let row3 = vector_double3(x: s2 * s3, y: -s3 * c2 * c1 - s1 * c3, z: -s3 * c2 * s1 + c3 * c1)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeJ2000ObliquityRotationMatrix() -> matrix_double3x3 {
        let s = sin(self.precessionNutaion.meanObliquityOfJ2000)
        let c = cos(self.precessionNutaion.meanObliquityOfJ2000)
        
        let row1 = vector_double3(x: 1.0, y: 0.0, z: 0.0)
        let row2 = vector_double3(x: 0.0, y: c, z: s)
        let row3 = vector_double3(x: 0.0, y: -s, z: c)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeMeanObliquityRotationMatrix() -> matrix_double3x3 {
        let s = sin(self.precessionNutaion.meanObliquityOfDate)
        let c = cos(self.precessionNutaion.meanObliquityOfDate)
        
        let row1 = vector_double3(x: 1.0, y: 0.0, z: 0.0)
        let row2 = vector_double3(x: 0.0, y: c, z: s)
        let row3 = vector_double3(x: 0.0, y: -s, z: c)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeTrueObliquityRotationMatrix() -> matrix_double3x3 {
        let s = sin(self.precessionNutaion.trueObliquityOfDate)
        let c = cos(self.precessionNutaion.trueObliquityOfDate)
        
        let row1 = vector_double3(x: 1.0, y: 0.0, z: 0.0)
        let row2 = vector_double3(x: 0.0, y: c, z: s)
        let row3 = vector_double3(x: 0.0, y: -s, z: c)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeGalacticCoordinatesRotationMatrix() -> matrix_double3x3 {
        let omega = Measurement(value: 284.01667, unit: UnitAngle.degrees).converted(to: .radians).value
        let inclination = Measurement(value: 62.8667, unit: UnitAngle.degrees).converted(to: .radians).value
        
        let s1 = sin(omega)
        let s2 = sin(inclination)
        let c1 = cos(omega)
        let c2 = cos(inclination)
        
        let row1 = vector_double3(x: c1, y: s1, z: 0.0)
        let row2 = vector_double3(x: -c2 * s1, y: c2 * c1, z: s2)
        let row3 = vector_double3(x: s2 * s1, y: -s2 * c1, z: c2)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
    
    private func makeHorizontalMatrix(location: CLLocation) -> matrix_double3x3 {
        let st = SiderealTime(date: date, location: location, precessionNutation: precessionNutaion)
        
        let s1 = sin(Measurement(value: location.coordinate.latitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        let s2 = sin(st.localMeanSiderealTime)
        let c1 = cos(Measurement(value: location.coordinate.latitude, unit: UnitAngle.degrees).converted(to: .radians).value)
        let c2 = cos(st.localMeanSiderealTime)
        
        let row1 = vector_double3(x: -s1 * c2, y: -s1 * s2, z: c1)
        let row2 = vector_double3(x: -s2, y: c2, z: 0.0)
        let row3 = vector_double3(x: c1 * c2, y: c1 * s2, z: s1)
        
        return matrix_double3x3(rows: [row1, row2, row3])
    }
}
