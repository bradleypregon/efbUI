//
//  FetchAirportMetar.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

enum AirportWxError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case invalidDecode
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Airport Wx API Error: Invalid URL."
    case .invalidResponse:
      return "Airport Wx API Error: Invalid Response."
    case .invalidDecode:
      return "Airport Wx API Error: Invalid Decode."
    }
  }
}

class AirportWxAPI {
  
  func fetchMetar(icao: String) async throws -> [AirportMETARSchema] {
    let url = "https://aviationweather.gov/cgi-bin/data/metar.php?ids=\(icao)&format=json"
    guard let url = URL(string: url) else {
      throw AirportWxError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportWxError.invalidResponse
    }
    
    guard let metars = try? JSONDecoder().decode([AirportMETARSchema].self, from: data) else {
      throw AirportWxError.invalidDecode
    }
    
    return metars
  }

  func fetchTAF(icao: String) async throws -> [String] {
    let url = "https://aviationweather.gov/cgi-bin/data/taf.php?ids=\(icao)"
    guard let url = URL(string: url) else {
      throw AirportWxError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportWxError.invalidResponse
    }
    
    guard let tafs = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) else {
      throw AirportWxError.invalidDecode
    }
    
    return tafs
  }
  
}
