//
//  AirportMetarAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

struct AirportMETARSchema: Decodable {
  let metarID: Int?
  let icaoID: String?
  let receiptTime: String?
  let obsTime: Int?
  let reportTime: String?
  let temp: Double?
  let dewp: Double?
  let wdir: Poly?
  let wspd: Poly?
  let wgst: Poly?
  let visib: Poly? // "10+" or 9, 8, etc.
  let altim: Double?
  let slp: Double?
  let qcField: Int?
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
  let metarType: String?
  let rawOb: String?
  let mostRecent: Int?
  let lat: Double?
  let lon: Double?
  let elev: Int?
  let prior: Int?
  let name: String?
  let clouds: [AirportMetarInfoClouds]?
  
  private enum CodingKeys: String, CodingKey {
    case metarID = "metar_id"
    case icaoID = "icaoId"
    case receiptTime, obsTime, reportTime, temp, dewp, wdir, wspd, wgst, visib, altim, slp, qcField, wxString, presTend, maxT, minT, maxT24, minT24, precip, pcp3hr, pcp6hr, pcp24hr, snow, vertVis, metarType, rawOb, mostRecent, lat, lon, elev, prior, name, clouds
  }
  
}

enum Poly: Decodable {
  case int(Int), string(String), double(Double)
  
  init(from decoder: Decoder) throws {
    if let intVal = try? decoder.singleValueContainer().decode(Int.self) {
      self = .int(intVal)
    } else if let stringVal = try? decoder.singleValueContainer().decode(String.self) {
      self = .string(stringVal)
    } else if let doubleVal = try? decoder.singleValueContainer().decode(Double.self) {
      self = .double(doubleVal)
    } else {
      throw DecodingError
        .typeMismatch(
          Poly.self,
          DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Value could not be decoded into an Int, String or Double."
          )
        )
    }
  }
  
  var asInt: Int? {
    switch self {
    case .int(let val):
      return val
    case .double(let val):
      return Int(val)
    case .string:
      return nil
    }
  }
  
  var asDouble: Double? {
    switch self {
    case .int(let val):
      return Double(val)
    case .double(let val):
      return val
    case .string:
      return nil
    }
  }
}

struct AirportMetarInfoClouds: Decodable {
  let cover: String?
  let base: Int?
}
