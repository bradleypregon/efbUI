//
//  AirportMetarAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

struct AirportMETARSchema: Decodable {
  let icaoId: String?
  let receiptTime: String
  let obsTime: Int
  let reportTime: String
  let temp: Double // min 0
  let dewp: Double?
  let wdir: Poly? // Int>=0 or Str (VRB) (null)
  let wspd: Int? // Int>=0 (null)
  let wgst: Int? // Int>=0 (null)
  let visib: Poly? // Number(double) or Str "10+" or 9, 8, etc.
  let altim: Double? // hPa
  let slp: Double? // sea-level press hPa
  let wxString: String?
  let presTend: Double?
  let maxT: Double?
  let minT: Double?
  let maxT24: Double?
  let minT24: Double?
  let precip: Double? // >=0
  let pcp3hr: Double? // >=0
  let pcp6hr: Double? // >=0
  let pcp24hr: Double? // >=0
  let snow: Double?
  let vertVis: Int? // >=0
  let metarType: String // METAR, SPECI, SYNOP, BUOY, CMAN
  let rawOb: String
  let lat: Double
  let lon: Double
  let elev: Int
  let name: String
  let clouds: [AirportMetarInfoClouds]
  let fltCat: WxCategory? // VFR, MVFR, IFR, LIFR, "" (blank)
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
  let cover: String // CLR, CAVOK, FEW, SCT, BKN, OVC, OVX
  let base: Int
  let top: Int?
}
