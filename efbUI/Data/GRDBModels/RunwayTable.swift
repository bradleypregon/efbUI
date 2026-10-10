//
//  RunwayGRDB.swift
//  efbUI
//
//  Created by Bradley Pregon on 9/23/26.
//

import GRDB

struct RunwayTable: Codable, Hashable, Identifiable, FetchableRecord, TableRecord {
  static let databaseTableName = "tbl_runways"
  let areaCode: String?
  let icaoCode: String?
  let airportIdentifier: String
  let runwayIdentifier: String
  let runwayLatitude: Double?
  let runwayLongitude: Double?
  let runwayGradient: Double?
  let runwayMagneticBearing: Double?
  let runwayTrueBearing: Double?
  let landingThresholdElevation: Int?
  let displacedThresholdDistance: Int?
  let thresholdCrossingHeight: Int?
  let runwayLength: Int?
  let runwayWidth: Int?
  let llzIdentifier: String?
  let llzMlsGlsCategory: String?
  let surfaceCode: Int?
  let id: String?
  
  enum CodingKeys: String, CodingKey {
    case areaCode = "area_code"
    case icaoCode = "icao_code"
    case airportIdentifier = "airport_identifier"
    case runwayIdentifier = "runway_identifier"
    case runwayLatitude = "runway_latitude"
    case runwayLongitude = "runway_longitude"
    case runwayGradient = "runway_gradient"
    case runwayMagneticBearing = "runway_magnetic_bearing"
    case runwayTrueBearing = "runway_true_bearing"
    case landingThresholdElevation = "landing_threshold_elevation"
    case displacedThresholdDistance = "displaced_threshold_distance"
    case thresholdCrossingHeight = "threshold_crossing_height"
    case runwayLength = "runway_length"
    case runwayWidth = "runway_width"
    case llzIdentifier = "llz_identifier"
    case llzMlsGlsCategory = "llz_mls_gls_category"
    case surfaceCode = "surface_code"
    case id = "id"
  }
  
  enum Columns {
    static let areaCode = Column(CodingKeys.areaCode.rawValue)
    static let icaoCode = Column(CodingKeys.icaoCode.rawValue)
    static let airportIdentifier = Column(CodingKeys.airportIdentifier.rawValue)
    static let runwayIdentifier = Column(CodingKeys.runwayIdentifier.rawValue)
    static let runwayLatitude = Column(CodingKeys.runwayLatitude.rawValue)
    static let runwayLongitude = Column(CodingKeys.runwayLongitude.rawValue)
    static let runwayGradient = Column(CodingKeys.runwayGradient.rawValue)
    static let runwayMagneticBearing = Column(CodingKeys.runwayMagneticBearing.rawValue)
    static let runwayTrueBearing = Column(CodingKeys.runwayTrueBearing.rawValue)
    static let landingThresholdElevation = Column(CodingKeys.landingThresholdElevation.rawValue)
    static let displacedThresholdDistance = Column(CodingKeys.displacedThresholdDistance.rawValue)
    static let thresholdCrossingHeight = Column(CodingKeys.thresholdCrossingHeight.rawValue)
    static let runwayLength = Column(CodingKeys.runwayLength.rawValue)
    static let runwayWidth = Column(CodingKeys.runwayWidth.rawValue)
    static let llzIdentifier = Column(CodingKeys.llzIdentifier.rawValue)
    static let llzMlsGlsCategory = Column(CodingKeys.llzMlsGlsCategory.rawValue)
    static let surfaceCode = Column(CodingKeys.surfaceCode.rawValue)
    static let id = Column(CodingKeys.id.rawValue)
  }
}

// Mock data for Previews
extension RunwayTable {
  static let mock: RunwayTable = RunwayTable(
    areaCode: "USA",
    icaoCode: "KJFK",
    airportIdentifier: "JFK",
    runwayIdentifier: "04L",
    runwayLatitude: 40.639751,
    runwayLongitude: -73.778925,
    runwayGradient: 0.3,
    runwayMagneticBearing: 44.0,
    runwayTrueBearing: 42.0,
    landingThresholdElevation: 13,
    displacedThresholdDistance: 0,
    thresholdCrossingHeight: 50,
    runwayLength: 12000,
    runwayWidth: 200,
    llzIdentifier: "IJFK",
    llzMlsGlsCategory: "ILS",
    surfaceCode: 1,
    id: "KJFK-04L"
  )

  static let mockKDSM: [RunwayTable] = [
    RunwayTable(
      areaCode: "USA",
      icaoCode: "K3",
      airportIdentifier: "KDSM",
      runwayIdentifier: "RW05",
      runwayLatitude: 41.52336667,
      runwayLongitude: -93.67711389,
      runwayGradient: 0.233,
      runwayMagneticBearing: 52.8,
      runwayTrueBearing: 53.719,
      landingThresholdElevation: 916,
      displacedThresholdDistance: 0,
      thresholdCrossingHeight: 55,
      runwayLength: 9004,
      runwayWidth: 150,
      llzIdentifier: "IDWW",
      llzMlsGlsCategory: "1",
      surfaceCode: 103,
      id: "KDSMK3RW05"
    ),
    RunwayTable(
      areaCode: "USA",
      icaoCode: "K3",
      airportIdentifier: "KDSM",
      runwayIdentifier: "RW13",
      runwayLatitude: 41.54560556,
      runwayLongitude: -93.67445278,
      runwayGradient: 0.5,
      runwayMagneticBearing: 131.3,
      runwayTrueBearing: 132.447,
      landingThresholdElevation: 913,
      displacedThresholdDistance: 0,
      thresholdCrossingHeight: 56,
      runwayLength: 9001,
      runwayWidth: 150,
      llzIdentifier: "IVGU",
      llzMlsGlsCategory: "1",
      surfaceCode: 103,
      id: "KDSMK3RW13"
    ),
    RunwayTable(
      areaCode: "USA",
      icaoCode: "K3",
      airportIdentifier: "KDSM",
      runwayIdentifier: "RW23",
      runwayLatitude: 41.53795,
      runwayLongitude: -93.65056667,
      runwayGradient: -0.233,
      runwayMagneticBearing: 232.8,
      runwayTrueBearing: 233.737,
      landingThresholdElevation: 937,
      displacedThresholdDistance: 0,
      thresholdCrossingHeight: 56,
      runwayLength: 9004,
      runwayWidth: 150,
      llzIdentifier: nil,
      llzMlsGlsCategory: nil,
      surfaceCode: 103,
      id: "KDSMK3RW23"
    ),
    RunwayTable(
      areaCode: "USA",
      icaoCode: "K3",
      airportIdentifier: "KDSM",
      runwayIdentifier: "RW31",
      runwayLatitude: 41.52896667,
      runwayLongitude: -93.65015556,
      runwayGradient: -0.5,
      runwayMagneticBearing: 311.3,
      runwayTrueBearing: 312.463,
      landingThresholdElevation: 958,
      displacedThresholdDistance: 0,
      thresholdCrossingHeight: 52,
      runwayLength: 9001,
      runwayWidth: 150,
      llzIdentifier: "IDSM",
      llzMlsGlsCategory: "3",
      surfaceCode: 103,
      id: "KDSMK3RW31"
    )
  ]
}
