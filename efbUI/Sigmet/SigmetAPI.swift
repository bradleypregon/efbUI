//
//  SigmetAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/10/24.
//

import Foundation
import Turf

enum SigmetAPIError: Error, LocalizedError {
  case badURL, badResponse, badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:      return "Sigmet API Error: Invalid URL."
    case .badResponse: return "Sigmet API Error: Invalid Response."
    case .badDecode:   return "Sigmet API Error: Invalid Decode."
    }
  }
}

class SigmetAPI {
  func fetchSigmet() async throws -> FeatureCollection {
    let url = "https://aviationweather.gov/api/data/sigmet?format=geojson&date=\(getDate())"
    
    guard let url = URL(string: url) else { throw SigmetAPIError.badURL }
    let (data, response) = try await URLSession.shared.data(from: url)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw SigmetAPIError.badResponse }
    return try JSONDecoder().decode(FeatureCollection.self, from: data)
  }
  
  // 20240309_171800 date_time OR ISO8601
  func getDate() -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd_HHmm"
    df.timeZone = .gmt
    return df.string(from: Date())
  }
  
}
