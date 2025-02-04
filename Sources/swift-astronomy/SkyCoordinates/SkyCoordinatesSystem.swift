//
//  SkyCoordinatesSystem.swift
//  Astronomy
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/09/18.
//

import Foundation

public enum SkyCoordinatesSystem: Sendable {
    case InternationalCelestialReferenceSystem
    case EquatorialCoordinatesMeanOfJ2000
    case EquatorialCoordinatesMeanOfDate
    case EquatorialCoordinatesTrueOfDate
    case EclipticCoordinatesMeanOfJ2000
    case EclipticCoordinatesMeanOfDate
    case EclipticCoordinatesTrueOfDate
    case GalacticCoordinates
    case HorizontalCoordinates
}
