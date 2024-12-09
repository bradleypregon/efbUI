//
//  RouteScreen.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/8/24.
//

import SwiftUI
import CoreLocation

struct WaypointsContainer: View {
  @Environment(RouteManager.self) private var routeManager
  @State private var popover: Bool = false
  
  var body: some View {
    WrappingHStack(models: routeManager.waypoints) { waypoint in
      WptView(wpt: waypoint)
    }
  }
  
  func WptView(wpt: MyWaypoint) -> some View {
    Button {
      print(wpt)
    } label: {
      Text(wpt.name)
        .padding(8)
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
    .popover(isPresented: $popover) {
      Button {
        remove(wpt)
      } label: {
        Text("Remove")
      }
    }
    .onLongPressGesture {
      popover.toggle()
    }
  }
  
  func remove(_ waypoint: MyWaypoint) {
    routeManager.waypoints.removeAll { $0 == waypoint }
  }
  
  func move(from source: IndexSet, to destination: Int) {
    routeManager.waypoints.move(fromOffsets: source, toOffset: destination)
  }
}

struct CustomInputView: View {
  @Environment(RouteManager.self) private var routeManager
  @State private var currentInput: String = ""
  
  var body: some View {
    TextField("Wpt...", text: $currentInput)
    // TODO: Query each db table (Airport, NBD, VOR) upon submission and return either an array or single object
    // airports, enroute_airways, enroute_waypoints, pathpoints, sids, stars, terminal_waypoints, vhfnavaids
    // TODO: How to handle airways?
    // If an array is returned, its probbaly a matching name, user needs to select appropriate
    // For instance, there are multiple VORs (or NBDs?) that have the same 3 letter identifier. Need to pick the right one
      .onReceive(currentInput.publisher) { val in
        if (val == " ") {
          let temp = MyWaypoint(lat: 41.4090, long: -92.9154, type: .gps, name: currentInput.trimmingCharacters(in: .whitespaces))
          routeManager.waypoints.append(temp)
          currentInput = ""
        }
      }
      .textFieldStyle(.roundedBorder)
      .frame(maxWidth: 300)
      .autocorrectionDisabled()
      .textInputAutocapitalization(.characters)
  }
}

struct RouteScreen: View {
  @Environment(SimBriefViewModel.self) private var simbrief
  
  var body: some View {
    // TODO: build array from ofp including origin, waypoints, destination
    // TODO: Color for Airports, color for Departures, color for Arrivals, color for TOC/TOD
    VStack {
      if let ofp = simbrief.ofp {
        WrappingHStack(models: ofp.navlog.filter { $0.type != "apt" }) { wpt in
          Button {
            print("\(wpt.ident) tapped")
          } label: {
            Text(wpt.isSidStar == "1" && wpt.ident != "TOC" && wpt.ident != "TOD" ? "\(wpt.via).\(wpt.ident)" : wpt.ident)
              .padding(8)
              .background(wpt.ident == "TOC" || wpt.ident == "TOD" ? Color.green : Color.blue)
              .foregroundStyle(.white)
              .clipShape(Capsule())
              .font(.caption)
          }
        }
        .frame(maxWidth: 600, maxHeight: 400)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      } else {
        Text("No simbrief ofp")
      }
      
      
      WaypointsContainer()
      CustomInputView()
    }
    
  }
}

//#Preview {
//  RouteScreen()
//}
