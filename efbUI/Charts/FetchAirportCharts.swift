//
//  FetchAirportCharts.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

enum AirportChartAPIError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case invalidDecode(Error)
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Airport Chart API Error: Invalid URL."
    case .invalidResponse:
      return "Airport Chart API Error: Invalid Response."
    case .invalidDecode(let message):
      return "Airport Chart API Error: Invalid Decode. \(message)"
    }
  }
}

class AirportChartAPI {
  func fetchCharts(icao: String) async throws -> AirportChartAPISchema {
    let url = "https://api.aviationapi.com/v1/charts?apt=\(icao)&group=1"
    guard let url = URL(string: url) else {
      throw AirportChartAPIError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportChartAPIError.invalidResponse
    }
    
    do {
      let decoded = try JSONDecoder().decode([String: AirportChartAPISchema].self, from: data)
      
      let temp2 = decoded.values.first
      
      guard let general = temp2?.general, let dp = temp2?.dp, let star = temp2?.star, let capp = temp2?.capp else { return AirportChartAPISchema(general: [], dp: [], star: [], capp: []) }
      
      return AirportChartAPISchema(general: general, dp: dp, star: star, capp: capp)
    } catch let error {
      throw AirportChartAPIError.invalidDecode(error)
    }
  }
  
}
