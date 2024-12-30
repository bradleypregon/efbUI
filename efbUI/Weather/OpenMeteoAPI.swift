//
//  OSMWeatherAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import Foundation

enum OpenMeteoError: Error, LocalizedError {
  case invalidURL
  case invalidResponse
  case invalidDecode
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid Response"
    case .invalidDecode:
      return "Invalid Decode"
    }
  }
}

class OpenMeteoAPI {
  func fetchWeather(latitude: Double, longitude: Double) async throws -> OpenMeteoSchema {
    let url = String("https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&daily=sunrise,sunset&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timeformat=unixtime&timezone=auto&forecast_days=1")
    
    guard let url = URL(string: url) else {
      throw OpenMeteoError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw OpenMeteoError.invalidResponse
    }
    
    guard let wx = try? JSONDecoder().decode(OpenMeteoSchema.self, from: data) else {
      throw OpenMeteoError.invalidDecode
    }
    
    return wx
  }
}
