//
//  PilotedgeAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 4/15/24.
//

import Foundation

class PilotedgeAPI {
  func fetchATIS(icao: String, completion: @escaping ([String]) -> ()) {
    let url = "https://www.pilotedge.net/atis/\(icao).txt"
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
