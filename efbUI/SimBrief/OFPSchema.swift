//
//  NewOFP.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/20/24.
//

import Foundation

struct OFPSchema: Decodable {
  let fetch: OFPFetch
  let params: OFPParams
  let general: OFPGeneral
  let origin: OFPAirport
  let destination: OFPAirport
  let alternate: [OFPAlternate]?
  let navlog: [OFPNavlog]
  let aircraft: OFPAircraft
  let fuel: OFPFuel
  let times: OFPTimes
  let weights: OFPWeights
  let weather: OFPWeather
  let files: OFPFiles
  
  struct OFPFetch: Decodable {
    let userID: String
    let status: String
    let time: String
  }
  
  struct OFPParams: Decodable {
    let requestID: String
    let userID: String
    let ofpLayout: String
    let airac: String
    let units: String
  }
  
  struct OFPGeneral: Decodable {
    let airline: String
    let flightNumber: String
    let cruiseProfile: String
    let alternateProfile: String
    let costIndex: String
    let initialAltitude: String
    let airDistance: String
    let passengers: String
    let route: String
    let routeIFPS: String
    let routeNavigraph: String
  }
  
  struct OFPAlternate: Decodable {
    let icaoCode: String
    let iataCode: String
    let faaCode: String
    let elevation: String
    let posLat: String
    let posLong: String
    let name: String
    let planRwy: String
    let transAlt: String
    let transLevel: String
    let cruiseAltitude: String
    let airDistance: String
    let trackTrue: String
    let trackMag: String
    let avgWindComp: String
    let avgWindDir: String
    let avgWindSpd: String
    let ete: String
    let route: String
    let routeIFPS: String
    let routeNavigraph: String
    let metar: String
    let metarTime: Quantum
    let metarCategory: Quantum
    let metarVisibility: Quantum
    let metarCeiling: Quantum
    let atis: [OFPATIS]?
    let notam: [OFPNOTAM]?
  }
  
  struct OFPAircraft: Decodable {
    let icaoCode: String
    let iataCode: String
    let baseType: String
    let name: String
    let reg: String
    let selcal: String
  }
  
  struct OFPFuel: Decodable {
    let block: String
    let takeoff: String
    let landing: String
  }
  
  struct OFPTimes: Decodable {
    let ete: String
    let schedDep: Date
    let schedArr: Date
  }
  
  struct OFPWeights: Decodable {
    let paxCountActual: String
    let paxWeight: String
    let bagWeight: String
    let cargo: String
    let estZFW: String
    let estTOW: String
    let estLDW: String
  }
  
  struct OFPWeather: Decodable {
    let origMETAR: String
    let destMETAR: String
    let altnMETAR: [String]
  }
  
  struct OFPFiles: Decodable {
    let directory: String
    let pdf: OFPPDF
  }
  
  struct OFPPDF: Decodable {
    let name: String
    let link: String
  }
  
}

struct OFPAirport: Decodable {
  let icaoCode: String
  let iataCode: String
  let faaCode: String
  let elevation: String
  let posLat: String
  let posLong: String
  let name: String
  let planRwy: String
  let transAlt: String
  let transLevel: String
  let metar: String
  let metarTime: Quantum
  let metarCategory: Quantum
  let metarVisibility: Quantum
  let metarCeiling: Quantum
  let atis: [OFPATIS]?
  let notam: [OFPNOTAM]?
}

struct OFPATIS: Decodable, Hashable {
  let network: String
  let issued: Date
  let letter: String
  let phonetic: String
  let type: String
  let message: String
}

struct OFPNOTAM: Decodable {
  let accountID: String
  let notamID: String
  let locationID: String
  let locationICAO: String
  let locationName: String
  let locationType: String
  let dateEffective: Date
  let dateExpire: Date
  let notamText: String
  let notamQcodeCategory: String
  let notamQcodeSubject: String
  let notamQcodeStatus: String
  let notamIsObstacle: Bool
}

struct OFPNavlog: Decodable, Identifiable, Hashable {
  var id: String = UUID().uuidString
  let ident: String
  let name: String
  let type: String
  let frequency: String
  let lat: String
  let long: String
  let stage: String
  let via: String
  let isSidStar: String
  let distance: String
  let track: String
  let altitude: String
  let windComponent: String
  let timeLeg: String
  let timeTotal: String
  let fuelLeg: String
  let fuelTotalUsed: String
  let oat: String
  let windDir: String
  let windSpd: String
  let shear: String
  
  enum CodingKeys: String, CodingKey {
    case ident, name, type, frequency, lat, long, stage, via, isSidStar, distance, track, altitude, windComponent, timeLeg, timeTotal, fuelLeg, fuelTotalUsed, oat, windDir, windSpd, shear
  }
}

enum Quantum: Decodable {
  case string(String), bool(Bool), date(Date)
  
  init(from decoder: Decoder) throws {
    if let string = try? decoder.singleValueContainer().decode(String.self) {
      self = .string(string)
      return
    }
    
    if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
      self = .bool(bool)
      return
    }
    
    if let date = try? decoder.singleValueContainer().decode(Date.self) {
      self = .date(date)
      return
    }
    
    throw QuantumError.missingValue
  }
  
  enum QuantumError: Error {
    case missingValue
  }
}
