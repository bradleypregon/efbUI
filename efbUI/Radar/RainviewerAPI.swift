//
//  RainviewerAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

enum RainviewerAPIError: Error, LocalizedError {
  case badURL
  case badResponse
  case badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:
      return "Rainviewer API Error: Invalid URL."
    case .badResponse:
      return "Rainviewer API Error: Invalid Response."
    case .badDecode:
      return "Rainviewer API Error: Invalid Decode."
    }
  }
}

class RainviewerAPI {
  func fetchRadar() async throws -> RainviewerSchema {
    guard let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json") else {
      throw RainviewerAPIError.badURL
    }
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw RainviewerAPIError.badResponse
    }
    
    guard let rainviewerData = try? JSONDecoder().decode(RainviewerSchema.self, from: data) else {
      throw RainviewerAPIError.badDecode
    }
    
    return rainviewerData
  }
}
