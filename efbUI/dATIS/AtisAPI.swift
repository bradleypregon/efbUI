//
//  AtisAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/7/24.
//

import Foundation

class AtisAPI {
  func fetchATIS(icao: String, completion: @escaping (AtisAPISchema) -> ()) {
    // https://datis.clowd.io/api/kden
    let url = "https://datis.clowd.io/api/\(icao)"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      
      do {
        let result = try JSONDecoder().decode(AtisAPISchema.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching \(icao) ATIS: \(error)")
      }
      
    }.resume()
  }
}
