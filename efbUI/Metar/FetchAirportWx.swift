//
//  FetchAirportMetar.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

class FetchAirportWx {
  func fetchMetarTaf(icao: String, completion: @escaping (AirportMetarInfo) -> ()) {
    // https://aviationweather.gov/cgi-bin/data/metar.php?ids=KDSM&format=json&taf=true
    let url = "https://aviationweather.gov/cgi-bin/data/metar.php?ids=\(icao)&format=json&taf=true"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      do {
        let result = try JSONDecoder().decode(AirportMetarInfo.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching \(icao) METAR/TAF: \(error)")
      }
      
    }.resume()
  }
  
}
