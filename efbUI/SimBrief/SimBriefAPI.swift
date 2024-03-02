//
//  SimBriefAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation
import Observation

@Observable
class SimBriefViewModel {
  var ofp: OFPSchema? {
    didSet {
      if let ofp {
        fetchOriginCharts(icao: ofp.origin.icaoCode)
        fetchDestCharts(icao: ofp.destination.icaoCode)
        if let altn = ofp.alternate?.first {
          fetchAltnCharts(icao: altn.icaoCode)
        }
      }
    }
  }
  let api = SimBriefAPI()
  let chartsAPI = FetchAirportCharts()
  
  var depCharts: DecodedArray<AirportChartAPISchema>?
  var arrCharts: DecodedArray<AirportChartAPISchema>?
  var altnCharts: DecodedArray<AirportChartAPISchema>?
  
  func fetchOFP(for id: String) {
    api.fetchLastFlightPlan(for: id) { schema in
      self.ofp = schema
    }
  }
  
  func fetchOriginCharts(icao: String) {
    chartsAPI.fetchCharts(icao: icao) { charts in
      self.depCharts = charts
    }
  }
  func fetchDestCharts(icao: String) {
    chartsAPI.fetchCharts(icao: icao) { charts in
      self.arrCharts = charts
    }
  }
  func fetchAltnCharts(icao: String) {
    chartsAPI.fetchCharts(icao: icao) { charts in
      self.altnCharts = charts
    }
  }
}

class SimBriefAPI {
  func fetchLastFlightPlan(for userID: String, completion: @escaping (OFPSchema) -> ()) {
//    let url = "https://www.simbrief.com/api/xml.fetcher.php?userid=\(userID)&json=v2"
    let url = "https://sb.pregonlabs.xyz/latest/\(userID)"

    guard let url = URL(string: url) else {
      print("Bad URL")
      return
    }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        print("Error in URLSession: \(String(describing: error?.localizedDescription))")
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
