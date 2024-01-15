//
//  AirportMetarAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

struct AirportMetarInfoElement: Decodable {
  let metarID: Int?
  let icaoID: String?
  let receiptTime: String?
  let obsTime: Int?
  let reportTime: String?
  let temp: Double?
  let dewp: Double?
  let wdir: Int?
  let wspd: Int?
  let wgst: Int?
  let visib: Visib // "10+" or 9, 8, etc.
  let altim: Double?
  let slp: Double?
  let wxString: String?
  let presTend: Double?
  let maxT: Double?
  let minT: Double?
  let maxT24: Double?
  let minT24: Double?
  let precip: Double?
  let pcp3hr: Double?
  let pcp6hr: Double?
  let pcp24hr: Double?
  let snow: Double?
  let vertVis: Double?
  let metarType: String
  let rawOb: String?
  let mostRecent: Int?
  let lat: Double
  let lon: Double
  let elev: Int
  let prior: Int?
  let name: String
  let clouds: [AirportMetarInfoClouds]?
  let rawTaf: String?
  
  private enum CodingKeys: String, CodingKey {
    case metarID = "metar_id"
    case icaoID = "icaoId"
    case receiptTime, obsTime, reportTime, temp, dewp, wdir, wspd, wgst, visib, altim, slp, wxString, presTend, maxT, minT, maxT24, minT24, precip, pcp3hr, pcp6hr, pcp24hr, snow, vertVis, metarType, rawOb, mostRecent, lat, lon, elev, prior, name, clouds, rawTaf
  }
  
  enum Visib: Decodable {
    case int(Int), string(String), double(Double)
    
    init(from decoder: Decoder) throws {
      if let intVal = try? decoder.singleValueContainer().decode(Int.self) {
        self = .int(intVal)
      } else if let stringVal = try? decoder.singleValueContainer().decode(String.self) {
        self = .string(stringVal)
      } else if let doubleVal = try? decoder.singleValueContainer().decode(Double.self) {
        self = .double(doubleVal)
      } else {
        throw DecodingError.typeMismatch(Visib.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Visib could not be decoded into Int or String"))
      }
    }
  }
}

struct AirportMetarInfoClouds: Decodable {
  let cover: String?
  let base: Int?
}

typealias AirportMetarInfo = [AirportMetarInfoElement]
