//
//  OSMWeatherAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import Foundation

class OSMWeatherAPI {
  /// https://openweathermap.org/api/one-call-api
  // TODO: Need a new local weather API
  // https://api.open-meteo.com/v1/forecast?latitude=12.3456&longitude=-12.345&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&daily=sunrise,sunset&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timeformat=unixtime&timezone=auto&forecast_days=1&format=flatbuffers
  
  //private let baseURL = "https://api.openweathermap.org/data/2.5/forecast?"
  //private let apiKey = Bundle.main.infoDictionary?["OSMWeatherAPI_Key"] as? String ?? ""
  //private let units = "imperial" /// standard, metric, imperial
  
  func fetchWeather(latitude: Double, longitude: Double, completion: @escaping (OpenMeteoSchema) -> () ) {
    
    //let coordinates = String("lat=\(latitude)&lon=\(longitude)")
    //let urlBuilder = String(baseURL+coordinates+"&units=\(units)&appid="+apiKey)
    let urlString = String("https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&daily=sunrise,sunset&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timeformat=unixtime&timezone=auto&forecast_days=1")
    guard let url = URL(string: urlString) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenMeteoSchema.self, from: data)
        DispatchQueue.main.async {
          completion(result)
        }
      } catch let error {
        print("Error fetching weather for: \(latitude), \(longitude): \(error)")
        print(data)
      }
      
    }.resume()
  }
}
