//
//  AirportCommunicationTable.swift
//  efbUI
//
//  Created by Bradley Pregon on 9/27/26.
//

import GRDB

struct AirportCommunicationTable: Codable, Hashable, FetchableRecord, TableRecord {
  static let databaseTableName = "tbl_airport_communication"
  let areaCode: String?
  let icaoCode: String?
  let airportIdentifier: String?
  let communicationType: String?
  let communicationFrequency: Double?
  let frequencyUnits: String?
  let serviceIndicator: String?
  let callsign: String?
  let latitude: Double?
  let longitude: Double?

  enum CodingKeys: String, CodingKey {
    case areaCode = "area_code"
    case icaoCode = "icao_code"
    case airportIdentifier = "airport_identifier"
    case communicationType = "communication_type"
    case communicationFrequency = "communication_frequency"
    case frequencyUnits = "frequency_units"
    case serviceIndicator = "service_indicator"
    case callsign = "callsign"
    case latitude = "latitude"
    case longitude = "longitude"
  }

  enum Columns {
    static let areaCode = Column(CodingKeys.areaCode.rawValue)
    static let icaoCode = Column(CodingKeys.icaoCode.rawValue)
    static let airportIdentifier = Column(CodingKeys.airportIdentifier.rawValue)
    static let communicationType = Column(CodingKeys.communicationType.rawValue)
    static let communicationFrequency = Column(CodingKeys.communicationFrequency.rawValue)
    static let frequencyUnits = Column(CodingKeys.frequencyUnits.rawValue)
    static let serviceIndicator = Column(CodingKeys.serviceIndicator.rawValue)
    static let callsign = Column(CodingKeys.callsign.rawValue)
    static let latitude = Column(CodingKeys.latitude.rawValue)
    static let longitude = Column(CodingKeys.longitude.rawValue)
  }
}

// Mock data for Previews
extension AirportCommunicationTable {
  static let mock: AirportCommunicationTable = AirportCommunicationTable(
    areaCode: "USA",
    icaoCode: "K6",
    airportIdentifier: "KJFK",
    communicationType: "ATI",
    communicationFrequency: 128.725,
    frequencyUnits: "V",
    serviceIndicator: nil,
    callsign: "KENNEDY ATIS",
    latitude: 40.639751,
    longitude: -73.778925
  )
}
