//
//  RouteScreen.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/8/24.
//

import SwiftUI

// Linked list
// Each node can be an airport, vor, navaid, departure, arrival, any type of navigation aid with a coordinate
// upon simbrief api fetch, compile route and load it into LinkedList

// Typical route format:
// head -> Airport
// nodes -> each route component
// tail -> Airport


// TODO: Instead of a heterogeneous list, create a custom type, and when the database is queried, just create custom object from what is returned from db
@Observable
class WaypointStore {
  var waypoints: [Waypoint] = []
}

struct Waypoint: Identifiable, Hashable {
  let id: String = UUID().uuidString
  let name: String
}

// TODO: Add Move and Delete functions like a normal vertical SwiftUI List
struct WaypointsContainer: View {
  @Environment(WaypointStore.self) private var waypointStore
  @State private var popover: Bool = false
  
  var body: some View {
    //      Ideal, but need Horizontal
    //      List {
    //        ForEach(waypointStore.waypoints) { waypoint in
    //          WptView(wpt: waypoint)
    //        }
    //        .onMove(perform: move)
    //      }
    //
    WrappingHStack(models: waypointStore.waypoints) { waypoint in
      WptView(wpt: waypoint)
    }
  }
  
  func WptView(wpt: Waypoint) -> some View {
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
  
  func remove(_ waypoint: Waypoint) {
    waypointStore.waypoints.removeAll { $0 == waypoint }
  }
  
  func move(from source: IndexSet, to destination: Int) {
    waypointStore.waypoints.move(fromOffsets: source, toOffset: destination)
  }
}

struct CustomInputView: View {
  @Environment(WaypointStore.self) private var waypointStore
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
          let wpt = Waypoint(name: currentInput.trimmingCharacters(in: .whitespaces))
          waypointStore.waypoints.append(wpt)
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
  @State var ofp: OFPSchema
  
  var body: some View {
    // TODO: build array from ofp including origin, waypoints, destination
    // TODO: Color for Airports, color for Departures, color for Arrivals, color for TOC/TOD
    VStack {
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
      
      WaypointsContainer()
      CustomInputView()
    }
    
  }
}

//#Preview {
//  RouteScreen()
//}
