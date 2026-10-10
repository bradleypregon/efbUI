//
//  AirportTable.swift
//  efbUI
//
//  Created by Bradley Pregon on 9/25/26.
//

import GRDB

struct AirportTable: Codable, Identifiable, Hashable, FetchableRecord, TableRecord {
  static let databaseTableName = "tbl_airports"
  let areaCode: String?
  let icaoCode: String
  let airportIdentifier: String
  let airportIdentifier3Letter: String?
  let airportName: String?
  let airportRefLat: Double?
  let airportRefLong: Double?
  let ifrCapibility: String?
  let longestRunwaySurfaceCode: String?
  let elevation: Int?
  let transitionAltitude: Int?
  let transitionLevel: Int?
  let speedLimit: Int?
  let speedLimitAltitude: Int?
  let iataAtaDesignator: String?
  var id: String?
  
  enum CodingKeys: String, CodingKey {
    case areaCode = "area_code"
    case icaoCode = "icao_code"
    case airportIdentifier = "airport_identifier"
    case airportIdentifier3Letter = "airport_identifier_3letter"
    case airportName = "airport_name"
    case airportRefLat = "airport_ref_lat"
    case airportRefLong = "airport_ref_long"
    case ifrCapibility = "ifr_capibility"
    case longestRunwaySurfaceCode = "longest_runway_surface_code"
    case elevation = "elevation"
    case transitionAltitude = "transition_altitude"
    case transitionLevel = "transition_level"
    case speedLimit = "speed_limit"
    case speedLimitAltitude = "speed_limit_altitude"
    case iataAtaDesignator = "iata_ata_designator"
    case id = "id"
  }
  
  enum Columns {
    static let areaCode = Column(CodingKeys.areaCode.rawValue)
    static let icaoCode = Column(CodingKeys.icaoCode.rawValue)
    static let airportIdentifier = Column(CodingKeys.airportIdentifier.rawValue)
    static let airportIdentifier3Letter = Column(CodingKeys.airportIdentifier3Letter.rawValue)
    static let airportName = Column(CodingKeys.airportName.rawValue)
    static let airportRefLat = Column(CodingKeys.airportRefLat.rawValue)
    static let airportRefLong = Column(CodingKeys.airportRefLong.rawValue)
    static let ifrCapibility = Column(CodingKeys.ifrCapibility.rawValue)
    static let longestRunwaySurfaceCode = Column(CodingKeys.longestRunwaySurfaceCode.rawValue)
    static let elevation = Column(CodingKeys.elevation.rawValue)
    static let transitionAltitude = Column(CodingKeys.transitionAltitude.rawValue)
    static let transitionLevel = Column(CodingKeys.transitionLevel.rawValue)
    static let speedLimit = Column(CodingKeys.speedLimit.rawValue)
    static let speedLimitAltitude = Column(CodingKeys.speedLimitAltitude.rawValue)
    static let iataAtaDesignator = Column(CodingKeys.iataAtaDesignator.rawValue)
    static let id = Column(CodingKeys.id.rawValue)
  }
}

// Mock data for Previews
extension AirportTable {
  static let mock: AirportTable = AirportTable(
    areaCode: "USA",
    icaoCode: "KJFK",
    airportIdentifier: "KJFK",
    airportIdentifier3Letter: "JFK",
    airportName: "John F Kennedy International",
    airportRefLat: 40.639751,
    airportRefLong: -73.778925,
    ifrCapibility: "Y",
    longestRunwaySurfaceCode: "ASPH",
    elevation: 13,
    transitionAltitude: 18000,
    transitionLevel: nil,
    speedLimit: 250,
    speedLimitAltitude: 10000,
    iataAtaDesignator: "JFK",
    id: "KJFK"
  )
}
