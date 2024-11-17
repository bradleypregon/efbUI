//
//  SigmetAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/10/24.
//

import Foundation

enum SigmetAPIError: Error, LocalizedError {
  case badURL
  case badResponse
  case badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:
      return "Sigmet API Error: Invalid URL."
    case .badResponse:
      return "Sigmet API Error: Invalid Response."
    case .badDecode:
      return "Sigmet API Error: Invalid Decode."
    }
  }
}

class SigmetAPI {
  func fetchSigmet() async throws -> SigmetSchema {
    let url = "https://aviationweather.gov/api/data/airsigmet?format=json&type=sigmet&hazard=conv,turb,ice,ifr&date=\(getDate())"
    
    guard let url = URL(string: url) else { throw SigmetAPIError.badURL }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw SigmetAPIError.badResponse }
    
    guard let sigmetData = try? JSONDecoder().decode(SigmetSchema.self, from: data) else {
      throw SigmetAPIError.badDecode
    }
    
    return sigmetData
  }
  
  // 20240309_171800Z
  // yyyymmdd_hhmmssZ
  private func getDate() -> String {
    let df = DateFormatter()
    df.dateFormat = "YYYYMMdd_HHmmss"
    df.timeZone = TimeZone(identifier: "UTC")
    let currentDate = Date()
    let zulu = df.string(from: currentDate)
    print("\(zulu)Z")
    return "\(zulu)Z"
  }
  
}
