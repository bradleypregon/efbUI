//
//  SimbriefTabDetails.swift
//  efbUI
//
//  Created by Bradley Pregon on 8/23/24.
//

import SwiftUI

struct SimbriefTabDetails: View {
  var airport: OFPAirport?
  var alternates: [OFPAlternate]?
  
  var body: some View {
    if let airport {
      Text("\(airport.icaoCode) - \(airport.name)")
      
      HStack {
        VStack {
          Text("ATIS")
            .fontWeight(.semibold)
          ScrollView(.vertical) {
            if let atis = airport.atis {
              ForEach(atis, id:\.self) { ati in
                Text(ati.network)
                  .fontWeight(.semibold)
                Text(ati.message)
                Divider()
              }
            }
          }
        }
        
        VStack {
          Text("NOTAM")
            .fontWeight(.semibold)
          ScrollView(.vertical) {
            if let notam = airport.notam {
              ForEach(notam, id:\.self) { notam in
                notamNode(notam: notam)
                Divider()
              }
            }
          }
        }
        
      }
      
    } else if let alternates {
      Text("")
    }
  }
  
  func notamNode(notam: OFPNOTAM) -> some View {
    VStack {
      Text("\(formatDate(notam.dateEffective)) - \(formatDate(notam.dateExpire))")
        .fontWeight(.semibold)
      Text(notam.notamText)
    }
  }
  
  /// Convert ISO-8601 Date to friendly String
  func formatDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .short
    df.timeZone = .gmt
    return df.string(from: date)
  }
}

//#Preview {
//  SimbriefTabDetails()
//}
