//
//  FetchAirportCharts.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

class FetchAirportCharts {
  // https://api.aviationapi.com/v1/charts?apt=klax&group=1
  func fetchCharts(icao: String, completion: @escaping (DecodedArray<AirportChartAPISchema>) -> ()) {
    
    let chartURL = "https://api.aviationapi.com/v1/charts?apt=\(icao)&group=1"
    guard let url = URL(string: chartURL) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      
      do {
        let result = try JSONDecoder().decode(DecodedArray<AirportChartAPISchema>.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching \(icao) Charts: \(error)")
      }
      
    }.resume()
  }
}
