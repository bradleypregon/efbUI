//
//  DBTableStructs.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/13/23.
//

import Foundation

struct AirportTable {
  let areaCode: String
  let icaoCode: String
  let airportIdentifier: String
  let airportIdentifier3Letter: String
  let airportName: String
  let airportRefLat: Double
  let airportRefLong: Double
  let ifrCapibility: String
  let longestRunwaySurfaceCode: String
  let elevation: Int64
  let transitionAltitude: Int64
  let transitionLevel: Int64
  let speedLimit: Int64
  let speedLimitAltitude: Int64
  let iataAtaDesignator: String
  let id: String
}

struct AirportCommunicationTable: Hashable {
  let areaCode: String
  let icaoCode: String
  let airportIdentifier: String
  let communicationType: String
  let communicationFrequency: Double
  let frequencyUnits: String
  let serviceIndicator: String
  let callsign: String
  let latitude: Double
  let longitude: Double
}

struct RunwayTable: Hashable {
  let areaCode: String
  let icaoCode: String
  let airportIdentifier: String
  let runwayIdentifier: String
  let runwayLatitude: Double
  let runwayLongitude: Double
  let runwayGradient: Double
  let runwayMagneticBearing: Double
  let runwayTrueBearing: Double
  let landingThresholdElevation: Int
  let displacedThresholdDistance: Int
  let thresholdCrossingHeight: Int
  let runwayLength: Int
  let runwayWidth: Int
  let llzIdentifier: String
  let llz_mls_gls_category: String
  let surfaceCode: Int
  let id: String
}

struct GateTable {
  let areaCode: String
  let airportIdentifier: String
  let icaoCode: String
  let gateIdentifier: String
  let gateLatitude: Double
  let gateLongitude: Double
  let name: String
}
