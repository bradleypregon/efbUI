//
//  AirportCalloutInfoView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/11/26.
//

import SwiftUI

struct AirportCalloutInfoView: View {
  @Environment(GRDBManager.self) private var grdb
  @State private var comms: [AirportCommunicationTable] = []
  @State var airport: AirportTable
  
  
  var body: some View {
    // TWR/Vatsim CTAF
    GroupBox("Info") {
      Grid(alignment: .leading) {
        GridRow {
          Text("TWR")
            .font(.subheadline)
          Text(getCommunicationType(comms: comms, type: "TWR"))
            .fontWeight(.semibold)
        }
        GridRow {
          Text("\(getATIS(comms: comms).first?.communicationType ?? "ATI n/a")")
            .font(.subheadline)
          Text("\(String(format: "%.3f", getATIS(comms: comms).first?.communicationFrequency ?? .zero))")
            .fontWeight(.semibold)
        }
        GridRow {
          Text("ELEV")
            .font(.subheadline)
          Text("\(airport.elevation ?? .zero)'")
            .fontWeight(.semibold)
        }
      }
    }
    .task(id: comms) {
      do {
        comms = try await grdb.fetchCommunications(for: airport.airportIdentifier)
        return
      } catch {
        print("Error fetching Comms for \(airport.airportIdentifier)")
      }
      comms = []
    }
  }
  
  func getCommunicationType(comms: [AirportCommunicationTable], type: String) -> String {
    if comms == [] { return "n/a" }
    if let freq = comms.first(where: { $0.communicationType == type && $0.frequencyUnits == "V"} )?.communicationFrequency?.string {
      return freq
    } else {
      return "n/a"
    }
  }
  
  func getATIS(comms: [AirportCommunicationTable]) -> [AirportCommunicationTable] {
    let types = ["ATI", "AWO", "ASO", "AWI", "AWS"]
    guard !comms.isEmpty else { return [] }
    
    let filter = comms.filter { $0.frequencyUnits == "V" && types.contains($0.communicationType ?? "") }
    guard !filter.isEmpty else { return [] }
    
    let sorted = sortAtis(wx: filter)
    return sorted
  }
  
  func sortAtis(wx: [AirportCommunicationTable]) -> [AirportCommunicationTable] {
    let ranking: [String: Int] = [
      "ATI": 1,
      "AWO": 2,
      "ASO": 3,
      "AWI": 4,
      "AWS": 5
    ]
    
    return wx.sorted { (a, b) -> Bool in
      if let a = a.communicationType, let b = b.communicationType {
        let rankA = ranking[a] ?? Int.max
        let rankB = ranking[b] ?? Int.max
        return rankA < rankB
      }
      return false
    }
  }
}

