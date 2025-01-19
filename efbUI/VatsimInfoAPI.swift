//
//  VatsimInfoAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/18/25.
//

import Foundation

struct VatsimInfoSchema: Codable {
  let data: VatsimInfoData
}

struct VatsimInfoData: Codable {
  let icao, iata, name: String
  let altitudeM, altitudeFt, transitionAlt: Int
  let transitionLevel: String
  let transitionLevelByAtc: Bool
  let city, country, divisionId: String
  let stations: [VatsimInfoStation]
  
  enum CodingKeys: String, CodingKey {
    case icao, iata, name
    case altitudeM = "altitude_m"
    case altitudeFt = "altitude_ft"
    case transitionAlt = "transition_alt"
    case transitionLevel = "transition_level"
    case transitionLevelByAtc = "transition_level_by_atc"
    case city, country
    case divisionId = "division_id"
    case stations
  }
}

struct VatsimInfoStation: Codable, Hashable {
  let callsign, name, frequency: String
  let ctaf: Bool
}

class VatsimInfoAPI {
  func fetchAirportInfo(for icao: String) async throws -> VatsimInfoSchema {
    let url = "https://my.vatsim.net/api/v2/aip/airports/\(icao)"
    guard let url = URL(string: url) else {
      throw VatsimInfoError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw VatsimInfoError.invalidResponse
    }
    
    do {
      let decoded = try JSONDecoder().decode(VatsimInfoSchema.self, from: data)
      
      return decoded
    } catch let error {
      throw VatsimInfoError.invalidDecode(error)
    }
  }
}

enum VatsimInfoError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case invalidDecode(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Vatsim AIP API Error: Invalid URL."
    case .invalidResponse:
      return "Vatsim AIP API Error: Invalid Response."
    case .invalidDecode(let message):
      return "Vatsim AIP API Error: Invalid Decode: \(message)"
    }
  }
}
