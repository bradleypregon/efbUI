//
//  SimbriefTabRoute.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/13/24.
//

import SwiftUI

struct SimbriefTabRoute: View {
  var route: [OFPNavlog]
  
  var body: some View {
    List(route) { route in
      SimbriefRouteListRow(leg: route)
    }
  }
}

struct SimbriefRouteListRow: View {
  var leg: OFPNavlog
  
  var body: some View {
    HStack(spacing: 20) {
      VStack {
        Text(leg.stage)
        Text(leg.via)
        Text(leg.type)
      }
      VStack {
        Text(leg.ident)
        Text(leg.name)
      }
      VStack(alignment: .leading) {
        Text(leg.lat)
        Text(leg.long)
      }
      VStack {
        Text("\(leg.distance)nm")
        Text("\(leg.track)º")
      }
      
    }
  }
}

#Preview {
  SimbriefTabRoute(route: [.init(ident: "OAK", name: "Oakland", type: "VOR", frequency: "Freq", lat: "12.34", long: "-54.32", stage: "Stage", via: "Via", isSidStar: "Is SID or STAR", distance: "Distance", track: "Track", altitude: "Altitude", windComponent: "Wind Component", timeLeg: "Time Log", timeTotal: "Time Total", fuelLeg: "Fuel LEg", fuelTotalUsed: "Total Fuel Used", oat: "OAT temp", windDir: "Wind DIR", windSpd: "Wind Speed", shear: "Wind Shear")])
}
