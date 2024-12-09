//
//  TabBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import CoreLocation
import Combine

enum efbTab: Equatable, Hashable {
  case airports
  case charts
  case routeCategories(RouteCategory)
  case map
  case scratchPad
  case settings
  case search
}

enum RouteCategory: Equatable, Hashable {
  case route
  case simbrief
}

struct TabBar: View {
  @State var selectedTab: efbTab = .airports
  @Environment(SimConnectShipObserver.self) private var ship
  @Environment(SimBriefViewModel.self) private var simbrief
  
  @State private var depNoticeTriggered: Bool = false
  @State private var inboundTriggered: Bool = false
  @State private var tenMileInbd: Bool = false
  @State private var fiveMileInbd: Bool = false
  
  private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
  
  var body: some View {
    TabView(selection: $selectedTab) {
      Tab(value: .search, role: .search) {
        SearchView(tab: $selectedTab)
      }
      Tab("Airport", systemImage: "scope", value: .airports) {
        AirportScreen(selectedTab: $selectedTab)
      }
      Tab("Charts", systemImage: "doc.on.doc", value: .charts) {
        ChartsView(selectedTab: $selectedTab)
          .ignoresSafeArea(edges: .top)
      }
      
      // MARK: Saving TabSection for a later date when fixed/functions better
//      TabSection {
//        Tab("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: efbTab.routeCategories(.route)) {
//          RouteScreen()
//        }
//        Tab("Simbrief", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: .routeCategories(.simbrief)) {
//          SimbriefScreen()
//        }
//      } header: {
//        Label("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
//      }
      
      Tab("Simbrief", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: .routeCategories(.simbrief)) {
        SimbriefScreen()
      }
      
      Tab("Map", systemImage: "map", value: .map) {
        MapScreen(selectedTab: $selectedTab)
          .ignoresSafeArea(edges: .top)
      }
      Tab("ScratchPad", systemImage: "square.and.pencil", value: .scratchPad) {
        ScratchPadView()
      }
      Tab("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: efbTab.routeCategories(.route)) {
        RouteScreen()
      }
      Tab("Settings", systemImage: "gear", value: .settings) {
        SettingsView()
      }
    }
    .onReceive(timer) { _ in
      guard let ofp = simbrief.ofp else { return }
      guard ship.ownship.value.coordinate.latitude != .zero else { return }
      
      let shipLocation = CLLocation(latitude: ship.ownship.value.coordinate.latitude, longitude: ship.ownship.value.coordinate.longitude)
      let originCoord = CLLocation(latitude: Double(ofp.origin.posLat) ?? .zero, longitude: Double(ofp.origin.posLong) ?? .zero)
      let destCoord = CLLocation(latitude: Double(ofp.destination.posLat) ?? .zero, longitude: Double(ofp.destination.posLong) ?? .zero)
      
      // if we are 20 miles past origin airport, notification for final call
      if (shipLocation.distance(from: originCoord) * 0.000621371 >= 20) && depNoticeTriggered == false {
        Toast.shared.present(title: "20mi from \(ofp.origin.icaoCode): Final Call", symbol: "airplane.departure")
        depNoticeTriggered = true
      }
      
      // if we are 30 miles inbound to de stinatino, notification for inbound
      if shipLocation.distance(from: destCoord) * 0.000621371 <= 30 && inboundTriggered == false  {
        Toast.shared.present(title: "30mi from \(ofp.destination.icaoCode): Inbound Call", symbol: "airplane.arrival")
        inboundTriggered = true
      }
      
      // 10 miles, make another call, 10 miles out
      if shipLocation.distance(from: destCoord) * 0.000621371 <= 10 && tenMileInbd == false {
        Toast.shared.present(title: "10mi from \(ofp.destination.icaoCode): 10 Mile Call", symbol: "airplane.arrival")
        tenMileInbd = true
      }
      
      // 5 miles, make another call
      if shipLocation.distance(from: destCoord) * 0.000621371 <= 5 && fiveMileInbd == false {
        Toast.shared.present(title: "5mi from \(ofp.destination.icaoCode): 5 Mile Call", symbol: "airplane.arrival")
        fiveMileInbd = true
      }
    }
  }
}

//#Preview {
//  TabBar()
//}
