//
//  AirportDBAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/21/22.
//

import Foundation

/*
class AirportDBAPI: ObservableObject {
  //https://airportdb.io/api/v1/airport/ICAO?apiToken=
  
  @Published var data: AirportDB?
  
  private let baseUrl = "https://airportdb.io/api/v1/airport/"
  private let apiKey = Bundle.main.infoDictionary?["AirportDB_Key"] as? String ?? ""
  
  func fetchAirportDBInfo(icao: String, completion: @escaping (AirportDB) -> ()) {
    let urlBuilder = String(baseUrl + icao + "?apiToken=" + apiKey)
    guard let url = URL(string: urlBuilder) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard data == data else { return }
      
      do {
        let decoder = JSONDecoder()
        let result = try decoder.decode(AirportDB.self, from: data!)
        
        DispatchQueue.main.async {
          self.data = result
          completion(result)
        }
      } catch let error {
        // handle error
        print(error)
      }
    }.resume()
  }
  
}
*/
