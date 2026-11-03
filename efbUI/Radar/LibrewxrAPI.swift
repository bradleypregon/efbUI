//
//  RainviewerAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

enum LibrewxrAPIError: Error, LocalizedError {
  case badURL, badResponse, badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:      return "LibreWXR API Error: Invalid URL."
    case .badResponse: return "LibreWXR API Error: Invalid Response."
    case .badDecode:   return "LibreEXR API Error: Invalid Decode."
    }
  }
}

class RainviewerAPI {
  func fetchRadar() async throws -> LibrewxrSchema {
    guard let url = URL(string: "https://api.librewxr.net/public/weather-maps.json") else {
      throw LibrewxrAPIError.badURL
    }
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw LibrewxrAPIError.badResponse }
    
    guard let rainviewerData = try? JSONDecoder().decode(LibrewxrSchema.self, from: data) else {
      throw LibrewxrAPIError.badDecode
    }
    
    return rainviewerData
  }
}
