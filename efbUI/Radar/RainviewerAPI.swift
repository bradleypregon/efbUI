//
//  RainviewerAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

class RainviewerAPI {
  func fetchRadar() async throws -> RainviewerSchema {
    guard let url = URL(string: "https://api.rainviewer.com/public/weather-maps.json") else {
      fatalError("Invalid Rainviewer API URL")
    }
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { fatalError("Error fetching Rainviewer API Data")}
    let rainviewerData = try JSONDecoder().decode(RainviewerSchema.self, from: data)
    return rainviewerData
  }
}
