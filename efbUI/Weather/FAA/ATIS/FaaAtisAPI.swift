//
//  AtisAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/7/24.
//

import Foundation

class FaaAtisAPI {
  func fetchATIS(icao: String) async throws -> [AtisAPISchema] {
    // https://datis.clowd.io/api/icao
    let endpoint = "https://datis.clowd.io/api/\(icao)"
    guard let url = URL(string: endpoint) else { throw FaaAtisError.badURL }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
      throw FaaAtisError.badResponse
    }
    
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([AtisAPISchema].self, from: data)
    } catch {
      throw FaaAtisError.badData
    }
  }
}

enum FaaAtisError: Error {
  case badURL, badResponse, badData
}
