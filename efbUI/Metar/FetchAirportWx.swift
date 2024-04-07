//
//  FetchAirportMetar.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

class FetchAirportWx {
  func fetchMetar(icao: String, completion: @escaping (AirportMETARSchema) -> ()) {
    // https://aviationweather.gov/cgi-bin/data/metar.php?ids=KDSM&format=json&taf=true
    let url = "https://aviationweather.gov/cgi-bin/data/metar.php?ids=\(icao)&format=json"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      do {
        let result = try JSONDecoder().decode(AirportMETARSchema.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching \(icao) METAR: \(error)")
      }
      
    }.resume()
  }
  
  func fetchTAF(icao: String, completion: @escaping ([String]) -> ()) {
    let url = "https://aviationweather.gov/cgi-bin/data/taf.php?ids=\(icao)"
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
