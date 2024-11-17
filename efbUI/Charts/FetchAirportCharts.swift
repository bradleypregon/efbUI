//
//  FetchAirportCharts.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

enum AirportChartAPIError: Error, LocalizedError {
  case badURL
  case badResponse
  case badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:
      return "Airport Chart API Error: Invalid URL."
    case .badResponse:
      return "Airport Chart API Error: Invalid Response."
    case .badDecode:
      return "Airport Chart API Error: Invalid Decode."
    }
  }
}

class AirportChartAPI {
  func fetchCharts(icao: String) async throws -> DecodedArray<AirportChartAPISchema> {
    let url = "https://api.aviationapi.com/v1/charts?apt=\(icao)&group=1"
    guard let url = URL(string: url) else {
      throw AirportChartAPIError.badURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AirportChartAPIError.badResponse
    }
    
    guard let chartData = try? JSONDecoder().decode(DecodedArray<AirportChartAPISchema>.self, from: data) else {
      throw AirportChartAPIError.badDecode
    }
    
    return chartData
  }
  
}
