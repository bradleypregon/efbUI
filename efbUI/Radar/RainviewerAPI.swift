//
//  RainviewerAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/4/24.
//

import Foundation

class RainviewerAPI {
  
  func fetchRadar(completion: @escaping (RainviewerSchema) -> ()) {
    let url = "https://api.rainviewer.com/public/weather-maps.json"
    guard let url = URL(string: url) else {
      print("invalid rainviewer url")
      return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard error == nil else {
        print("rainviewer error: \(String(describing: error))")
        return
      }
      guard let data = data else {
        print("error with rainviewer data")
        return
      }
      
      do {
        let decoder = JSONDecoder()
        let data = try decoder.decode(RainviewerSchema.self, from: data)
        Task {
          completion(data)
        }
      } catch {
        print("Error fetching/decoding radar: \(error)")
      }
    }.resume()
  }
}
