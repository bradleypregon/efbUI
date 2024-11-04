//
//  MapScreenWaypointView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/4/24.
//

import SwiftUI

struct MapScreenWaypointView: View {
  @State private var popoverPresented: Bool = false
  var wpt: OFPNavlog
  
  var body: some View {
    Button {
      popoverPresented.toggle()
    } label: {
      VStack {
        Image(systemName: wpt.ident == "TOC" || wpt.ident == "TOD" ? "bolt.horizontal.fill" : "triangle.fill")
          .foregroundStyle(wpt.ident == "TOC" || wpt.ident == "TOD" ? .green : .blue)
        Text(wpt.ident)
          .padding(6)
          .background(.blue)
          .foregroundStyle(.white)
          .clipShape(Capsule())
          .font(.caption)
      }
    }
    .popover(isPresented: $popoverPresented) {
      List {
        Text("Ident: \(wpt.ident)")
        Text("Name: \(wpt.name)")
        Text("Type: \(wpt.type)")
        Text("Freq: \(wpt.frequency)")
        Text("Via: \(wpt.via)")
        Text("Alt: \(wpt.altitude)")
        Text("W/C: \(wpt.windComponent)")
        Text("Time leg: \(wpt.timeLeg)")
        Text("Time Total: \(wpt.timeTotal)")
        Text("Fuel Leg: \(wpt.fuelLeg)")
        Text("Fuel Total: \(wpt.fuelTotalUsed)")
        Text("Wind: \(wpt.windDir)/\(wpt.windSpd)")
        Text("Shear: \(wpt.shear)")
      }
      .font(.caption)
      .listStyle(.plain)
      .background(.bar)
      .frame(idealWidth: 200, idealHeight: 400)
    }
  }
}
