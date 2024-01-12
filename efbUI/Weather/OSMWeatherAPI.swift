//
//  OSMWeatherAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import Foundation

class OSMWeatherAPI {
  /// https://openweathermap.org/api/one-call-api
  private let baseURL = "https://api.openweathermap.org/data/2.5/onecall?"
  private let apiKey = Bundle.main.infoDictionary?["OSMWeatherAPI_Key"] as? String ?? ""
  private let units = "imperial" /// standard, metric, imperial
  
  func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (OSMWeatherSchema) -> () ) {
    
    let coordinates = String("lat=\(latitude)&lon=\(longitude)")
    let urlBuilder = String(baseURL+coordinates+"&units=\(units)&appid="+apiKey)
    guard let url = URL(string: urlBuilder) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(OSMWeatherSchema.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching weather for: \(latitude), \(longitude): \(error)")
      }
      
    }.resume()
  }
}
