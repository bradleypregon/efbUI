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
  var windDir: Double? // treat VRB wind as NIL for calculation
  
  @State private var bestRunways: [RunwayTable] = []
  
  @State private var bestRunway: [RankedRunway] = []
  
  var body: some View {
    ForEach(bestRunways) { runway in
      Text(runway.runwayIdentifier)
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
  
  /**
   Returns the best runways by wind direction within a specified tolerance
   
   Calculates the difference between runway heading and wind direction for each runway.
   After finding the runway with the lowest difference, return other runways that are within a tolerance of difference
   - Complexity: O(n)
   */
  func bestRunway(by wind: Double?, for runways: [RunwayTable], with tolerance: Double) -> [RunwayTable] {
    // Wind is greater than 0 and runways is not empty
    guard let wind = wind, wind > 0, !runways.isEmpty else { return [] }
    let runways = runways.filter { $0.runwayMagneticBearing != nil }
    
    // Map [RunwayTable] to [(RunwayTable, Difference)]
    // where Difference is (runway heading - wind direction)
    // Target = runway with lowest difference
    let runwayDiff: [(RunwayTable, Double)] = runways.map { ($0, abs($0.runwayMagneticBearing ?? .zero - wind)) }
    let target = runwayDiff.min { $0.1 < $1.1 }
    guard let target = target else { return [] }
    
    // Filter runways where Difference is within tolerance
    let runwayFilter = runwayDiff.filter { abs($0.1 - target.1) <= tolerance }
    
    // Drop Difference, only return runways
    let best = runwayFilter.map { $0.0 }
    return best
  }

  /**
   Returns the best runways by length within a specified tolerance
   
   If RW05 is 9000' and RW31 is 9001', with a tolerance of 5', return both
   */
  func bestRunway(for runways: [RunwayTable], with tolerance: Int) -> [RunwayTable] {
    let longest: RunwayTable? = runways.max { pre, post in
      guard let len1 = pre.runwayLength else { return false }
      guard let len2 = post.runwayLength else { return true }
      return len1 < len2
    }
    
    guard let longest = longest, let longestLength = longest.runwayLength else { return [] }
    
    let filterByTolerance = runways.filter { rwy in
      guard let len = rwy.runwayLength else { return false }
      return abs(longestLength - len) <= tolerance
    }
    
    return filterByTolerance
  }
  
  func calcBestRunways(from runways: [RunwayTable]) -> [RunwayTable] {
    let bestByWind = bestRunway(by: windDir, for: runways, with: 2)
    let longest: [RunwayTable] = bestRunway(for: runways, with: 1)
    
    let match: [RunwayTable] = bestByWind.filter(longest.contains)
    return match
  }
}

struct RankedRunway: Identifiable {
  let runway: RunwayTable
  let isbestWind: Bool
  let isLongest: Bool
  var id: RunwayTable.ID { runway.id }
}
