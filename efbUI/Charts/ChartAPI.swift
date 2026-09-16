//
//  FetchAirportCharts.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

enum ChartAPIError: Error, LocalizedError {
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

class ChartAPI {
  func fetchCharts(icao: String) async throws -> ChartAPISchema {
    let url = "https://api-v2.aviationapi.com/v2/charts?airport=\(icao)"
    guard let url = URL(string: url) else {
      throw ChartAPIError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw ChartAPIError.invalidResponse
    }
    
    do {
      return try JSONDecoder().decode(ChartAPISchema.self, from: data)
    } catch let error {
      print("Airport Chart API invalid decode")
      throw ChartAPIError.invalidDecode(error)
    }
  }
  
}
