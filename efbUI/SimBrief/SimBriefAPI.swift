//
//  SimBriefAPI.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/15/24.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class SimBriefViewModel: Sendable {
  var ofp: OFPSchema? {
    didSet {
      if let ofp {
        Task {
          depCharts = await fetchCharts(icao: ofp.origin.icaoCode)
          arrCharts = await fetchCharts(icao: ofp.destination.icaoCode)
          if let altn = ofp.alternate?.first {
            altnCharts = await fetchCharts(icao: altn.icaoCode)
          }
        }
      }
    }
  }

  let api = SimBriefAPI()
  var sbAPIErrorMessage: String?
  
  var depCharts: AirportChartAPISchema?
  var arrCharts: AirportChartAPISchema?
  var altnCharts: AirportChartAPISchema?
  
  func fetchOFP(for id: String) async {
    do {
      self.ofp = try await SimBriefAPI().fetchFlightPlan(for: id)
    } catch let error as SimBriefError {
      self.sbAPIErrorMessage = error.localizedDescription
    } catch {
      self.sbAPIErrorMessage = "SimBrief API Error: An unknown error occured."
    }
  }
  
  func fetchCharts(icao: String) async -> AirportChartAPISchema? {
    do {
      return try await AirportChartAPI().fetchCharts(icao: icao)
    } catch {
      return nil
    }
  }

}

enum SimBriefError: Error, LocalizedError {
  case badURL
  case badResponse
  case badDecode
  
  var errorDescription: String? {
    switch self {
    case .badURL:
      return "SimBrief API Error: Invalid URL. Simbrief ID may be invalid."
    case .badResponse:
      return "SimBrief API Error: Invalid Response. Simbrief may be offline."
    case .badDecode:
      return "SimBrief API Error: Invalid Decode. Simbrief ID may be invalid, or there is no route."
    }
  }
}

class SimBriefAPI {
  func fetchFlightPlan(for userID: String) async throws -> OFPSchema {
    let url = "https://efb.pregonlabs.xyz/latest/\(userID)"
    guard let url = URL(string: url) else {
      throw SimBriefError.badURL
    }
    
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw SimBriefError.badResponse
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    guard let ofp = try? decoder.decode(OFPSchema.self, from: data) else {
      throw SimBriefError.badDecode
    }
    return ofp
  }
  
}
