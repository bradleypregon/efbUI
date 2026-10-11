//
//  AirportCalloutRunwayView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/11/26.
//

import SwiftUI

struct AirportCalloutRunwayView: View {
  @Environment(GRDBManager.self) private var grdb
  let icao: String
  @State private var bestRunways: [RunwayTable] = []
  
  var windDir: Double? // treat VRB wind as NIL for calculation
  
  var body: some View {
    // Calculate best runway based on winds, length, ATIS? and incl. NOTAMS?
    GroupBox("Best Runway") {
      if bestRunways.isEmpty { EmptyView() }
      
      ForEach(bestRunways) { runway in
        Text(runway.runwayIdentifier)
      }
    }
    .task {
      do {
        let runways = try await grdb.fetchRunways(for: icao)
        bestRunways = calcBestRunways(from: runways)
      } catch {
        print("Error fetching runways or calculating best runway: \(error)")
      }
    }
  }
  
  // #1 Runways from ATIS, #2 from Length+Wind, #3 from Length (fallback)
  // Incl. NOTAMs -> Runway 05 cant be best if NOTAM shows that runway closed
  func calcBestRunways(from runways: [RunwayTable]) -> [RunwayTable] {
    return []
  }
}

