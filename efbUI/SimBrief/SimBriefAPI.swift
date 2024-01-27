//
//  SimBriefAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation

class SimBriefAPI {
  func fetchLastFlightPlan(for userID: String, completion: @escaping (OFPSchema) -> ()) {
//    let url = "https://www.simbrief.com/api/xml.fetcher.php?userid=\(userID)&json=v2"
    let url = "https://sb.pregonlabs.us/latest/\(userID)"

    guard let url = URL(string: url) else {
      print("Bad URL")
      return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        print("Error in URLSession: \(error)")
        return
      }
      guard let data = data else {
        print("Error in data")
        return
      }
      
      do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let data = try decoder.decode(OFPSchema.self, from: data)
        DispatchQueue.main.async {
          completion(data)
        }
      } catch let error {
        print("Error fetching SimBrief Route: \(error)")
      }
      
    }.resume()
    
  }
}
