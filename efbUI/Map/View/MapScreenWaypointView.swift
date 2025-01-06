//
//  MapScreenWaypointView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/4/24.
//

import SwiftUI

struct MapScreenWaypointView: View {
  @State private var popoverPresented: Bool = false
  var wpt: MyWaypoint
  
  var body: some View {
    Button {
      popoverPresented.toggle()
    } label: {
      VStack {
        Image(systemName: "triangle.fill")
          .foregroundStyle(.blue)
        Text(wpt.identifier)
          .padding(6)
          .background(.blue)
          .foregroundStyle(.white)
          .clipShape(Capsule())
          .font(.caption)
      }
    }
    .popover(isPresented: $popoverPresented) {
      List {
//        Text("Ident: \(wpt.ident)")
//        Text("Name: \(wpt.name)")
//        Text("Type: \(wpt.type)")
//        Text("Freq: \(wpt.frequency)")
//        Text("Via: \(wpt.via)")
//        Text("Alt: \(wpt.altitude)")
//        Text("W/C: \(wpt.windComponent)")
//        Text("Time leg: \(wpt.timeLeg)")
//        Text("Time Total: \(wpt.timeTotal)")
//        Text("Fuel Leg: \(wpt.fuelLeg)")
//        Text("Fuel Total: \(wpt.fuelTotalUsed)")
//        Text("Wind: \(wpt.windDir)/\(wpt.windSpd)")
//        Text("Shear: \(wpt.shear)")
        Text("Ident: \(wpt.identifier)")
        Text("Name: \(wpt.name)")
        Text("Type: \(wpt.type)")
        Text("Freq: \(000.000)")
      }
      .font(.caption)
      .listStyle(.plain)
      .background(.bar)
      .frame(idealWidth: 200, idealHeight: 400)
    }
  }
}
