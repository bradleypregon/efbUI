//
//  SigmetAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/10/24.
//

import Foundation

class SigmetAPI {
  func fetchSigmet(completion: @escaping (SigmetSchema) -> ()) {
    let url = "https://aviationweather.gov/api/data/airsigmet?format=json&type=sigmet&hazard=conv,turb,ice,ifr&date=\(getDate())"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard error == nil else { return }
      guard let data = data else { return }
      
      do {
        let result = try JSONDecoder().decode(SigmetSchema.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching Sigmet: \(error)")
      }
    }.resume()
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
