//
//  SimBriefAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation
import XMLCoder

class SimBriefAPI {
  func fetchLastFlightPlan(for userID: String, completion: @escaping (SimBriefOFP) -> ()) {
    // https://www.simbrief.com/api/xml.fetcher.php?userid=userID
    let url = "https://www.simbrief.com/api/xml.fetcher.php?userid=\(userID)"
    guard let url = URL(string: url) else { return }
    
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      // 
      do {
        // decode XML Data
        let data = try XMLDecoder().decode(SimBriefOFP.self, from: data)
//        let encodedXML = try? XMLEncoder().encode(data, withRootKey: "OFP")
        
        DispatchQueue.main.async {
          completion(data)
        }
        
      } catch let error {
        print("Error fetching SimBrief Route for: \(userID): \(error)")
      }
      
    }.resume()
  }
}
