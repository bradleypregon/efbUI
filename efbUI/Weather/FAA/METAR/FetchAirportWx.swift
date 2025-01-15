//
//  FetchAirportMetar.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation
import CoreLocation.CLLocation

enum AirportWxError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case invalidDecode(Error)
  case invalidStrings
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Airport Wx API Error: Invalid URL."
    case .invalidResponse:
      return "Airport Wx API Error: Invalid Response."
    case .invalidDecode(let message):
      return "Airport Wx API Error: Invalid Decode. \(message)"
    case .invalidStrings:
      return "Airport Wx API Error: Invalid String Array Response."
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
    
    do {
      let metars = try JSONDecoder().decode([AirportMETARSchema].self, from: data)
      return metars
    } catch {
//      let rawResponse = String(data: data, encoding: .utf8)
      throw AirportWxError.invalidDecode(error)
    }
  }
  
  func fetchMetar(icao: String, at time: Date) async throws -> [AirportMETARSchema] {
    let url = "https://aviationweather.gov/cgi-bin/data/metar.php?ids=\(icao)&format=json"
    guard let url = URL(string: url) else {
      throw AirportWxError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportWxError.invalidResponse
    }
    
    do {
      let metars = try JSONDecoder().decode([AirportMETARSchema].self, from: data)
      return metars
    } catch {
      throw AirportWxError.invalidDecode(error)
    }
  }
  
  func fetchBBox(ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D) async throws -> [AirportMETARSchema] {
    let url = "https://aviationweather.gov/api/data/metar?bbox=\(sw.latitude),\(sw.longitude),\(ne.latitude),\(ne.longitude)&format=json"
    guard let url = URL(string: url) else {
      throw AirportWxError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportWxError.invalidResponse
    }
    
    do {
      let metars = try JSONDecoder().decode([AirportMETARSchema].self, from: data)
      return metars
    } catch let error {
      throw AirportWxError.invalidDecode(error)
    }
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
      throw AirportWxError.invalidStrings
    }
    return tafs
  }
  
}
