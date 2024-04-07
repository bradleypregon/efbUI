//
//  AirportTAFAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/16/24.
//

/*
import Foundation

struct AirportTAFAPISchemaElement: Decodable {
  let tafId: Int?
  let icaoId: String?
  let dbPopTime: String?
  let bulletinTime: String?
  let issueTime: String?
  let validTimeFrom: Int?
  let validTimeTo: Int?
  let rawTAF: String?
  let mostRecent: Int?
  let remarks: String?
  let lat: Double?
  let long: Double?
  let elev: Int?
  let prior: Int?
  let name: String?
  let fcsts: [AirportTAFForecast]?
}

struct AirportTAFForecast: Decodable {
  let timeGroup: Int?
  let timeFrom: Int?
  let timeTo: Int?
  let timeBec: Int?
  let fcstChange: String?
  let probability: Int?
  let wdir: Custom?
  let wspd: Int?
  let wgst: Int?
  let wshearHgt: Int?
  let wshearDir: Int?
  let wshearSpd: Int?
  let visib: Custom?
  let altim: Int?
  let vertVis: Int?
  let wxString: String?
  let notDecoded: String?
  let clouds: [AirportTAFClouds]?
  let icgTurb: [AirportTAFIcgTurb]?
  let temp: [AirportTAFTemp]?
  
  enum Custom: Decodable {
    case int(Int), string(String), double(Double)
    
    init(from decoder: Decoder) throws {
      if let intVal = try? decoder.singleValueContainer().decode(Int.self) {
        self = .int(intVal)
      } else if let stringVal = try? decoder.singleValueContainer().decode(String.self) {
        self = .string(stringVal)
      } else if let doubleVal = try? decoder.singleValueContainer().decode(Double.self) {
        self = .double(doubleVal)
      } else {
        throw DecodingError.typeMismatch(Custom.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Decoding TAF Custom: Could not decode value into Int, Double or String"))
      }
    }
  }
}

struct AirportTAFClouds: Decodable {
  let cover: String?
  let base: Int?
  let type: String?
}

struct AirportTAFIcgTurb: Decodable {
  let variation: String?
  let intensity: Int?
  
  enum CodingKeys: String, CodingKey {
    case variation = "var"
    case intensity
  }
}

struct AirportTAFTemp: Decodable {
  let validTime: Int?
  let sfcTemp: Int?
  let maxOrMix: String?
}

typealias AirportTAFSchema = [AirportTAFAPISchemaElement]
*/
