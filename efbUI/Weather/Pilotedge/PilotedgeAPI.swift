//
//  PilotedgeAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/15/24.
//

import Foundation

enum PilotedgeAPIError: Error, LocalizedError {
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

class PilotedgeAPI {
  func fetchATIS(icao: String) async throws -> [String] {
    let url = "https://www.pilotedge.net/atis/\(icao).txt"
    guard let url = URL(string: url) else {
      throw PilotedgeAPIError.invalidURL
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw PilotedgeAPIError.invalidResponse
    }
    
    guard let atis = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) else {
      throw PilotedgeAPIError.invalidDecode
    }
    
    return atis
  }
  
  func fetchATIS(icao: String, completion: @escaping ([String]) -> ()) {
    let url = "https://www.pilotedge.net/atis/\(icao).txt"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      
      if let result = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) {
        DispatchQueue.main.async {
          completion(result)
        }
      }
    }.resume()
  }
}
