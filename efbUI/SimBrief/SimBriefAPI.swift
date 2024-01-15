//
//  SimBriefAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation

class SimBriefAPI {
  func fetchLastFlightPlan(for userID: String) {
    // https://www.simbrief.com/api/xml.fetcher.php?userid=userID
    let url = "https://www.simbrief.com/api/xml.fetcher.php?userid=\(userID)"
    guard let url = URL(string: url) else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else { return }
      guard let data = data else { return }
      // 
      do {
        // decode XML Data
        let xmlParser = XMLParser(data: data)
        let temp = xmlParser.parse()
        print(temp)
      } catch let error {
        print("Error fetching SimBrief Route for: \(userID): \(error)")
      }
      
    }.resume()
  }
}
