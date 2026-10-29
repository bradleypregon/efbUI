//
//  TabBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import CoreLocation
import Combine
import SwiftData

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
  @Environment(AppCoordinator.self) private var appCoordinator: AppCoordinator
  @Environment(SimConnectShipObserver.self) private var ship
  @Environment(RouteManager.self) private var route
  @Environment(ToastManager.self) private var toastManager
  @Environment(ScratchPadManager.self) private var pad
  
  @State private var depTriggered: Bool = false
  @State private var inbTriggered: Bool = false
  @State private var atisTriggered: Bool = false
  @State private var shortInbTriggered: Bool = false
  @State private var finalTriggered: Bool = false
  
  var body: some View {
    @Bindable var appCoord = appCoordinator
    
    TabView(selection: $appCoord.tab) {
      Tab(value: .search, role: .search) {
        SearchView()
      }
      Tab("Airport", systemImage: "scope", value: .airports) {
        AirportDetailView()
      }
      Tab("Charts", systemImage: "doc.on.doc", value: .charts) {
        ChartsView()
          .ignoresSafeArea(edges: .top)
      }
      Tab("Simbrief", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: .routeCategories(.simbrief)) {
        SimbriefScreen()
      }
      Tab("Map", systemImage: "map", value: .map) {
        MapScreen()
      }
      Tab("Pad", systemImage: "square.and.pencil", value: .scratchPad) {
        ScratchPadView()
      }
      Tab("Route", systemImage: "point.topleft.down.to.point.bottomright.curvepath", value: efbTab.routeCategories(.route)) {
        RouteScreen()
      }
      Tab("Settings", systemImage: "gear", value: .settings) {
        SettingsView()
      }
    }
    .overlay {
      if pad.isOpen {
        FloatingPadView()
      }
    }
    /*
    .onReceive(ship.ownship) { ship in
      guard
        route.waypoints.count > 0,
        let origin = route.waypoints.first,
        let dest = route.waypoints.last
      else { return }
      
      guard ship.coordinate.latitude != .zero else { return }
      guard let settings = userSettings.first else { return }
      
      let shipCoord = CLLocation(latitude: ship.coordinate.latitude, longitude: ship.coordinate.longitude)
      let originCoord = CLLocation(latitude: origin.lat, longitude: origin.long)
      let destCoord = CLLocation(latitude: dest.lat, longitude: dest.long)
      
      // Origin Departure Final Call
      if (shipCoord.distance(from: originCoord) * 0.000621371 >= Double(settings.outboundDistance) && !depTriggered) {
        pushToast(image: "airplane.departure", title: "\(settings.outboundDistance)nm from \(origin.identifier): Final Call")
        depTriggered = true
      }
      
      // Inbound
      if (shipCoord.distance(from: destCoord) * 0.000621371 <= Double(settings.inboundDistance) && !inbTriggered) {
        pushToast(image: "airplane.arrival", title: "\(settings.inboundDistance)nm from \(dest.identifier): Inbound")
        inbTriggered = true
      }
      
      // ATIS
      if (shipCoord.distance(from: destCoord) * 0.000621371 <= Double(settings.atisDistance) && !atisTriggered) {
        // fetch atis/awos/ASOS? frequency from destination if airport
        guard dest.type == .airport else { return }
        //let comms = SQLiteManager.shared.getAirportComms(dest.identifier)
        //guard !comms.isEmpty else { return }
        
        
        // Try AWO if not ATI. How to handle multiple frequencies?
        // frequency_units == V
        //  if service_indicator starts with L: Arrival atis (D is dep)
        // if neither AWO nor ATI, recommend trying METAR or nearby airport
        
        pushToast(image: "airplane.arrival", title: "ATIS for \(dest.identifier): \("000.000")")
        atisTriggered = true
      }
      
      // Short Inbound
      if (shipCoord.distance(from: destCoord) * 0.000621371 <= Double(settings.shortInboundDistance) && !shortInbTriggered) {
        pushToast(image: "airplane.arrival", title: "\(settings.shortInboundDistance)nm from \(dest.identifier): Short Inbound")
        shortInbTriggered = true
      }
      
      // Final
      if (shipCoord.distance(from: destCoord) * 0.000621371 <= Double(settings.finalDistance) && !finalTriggered) {
        pushToast(image: "airplane.arrival", title: "\(settings.shortInboundDistance)nm from \(dest.identifier): Final Approach")
        finalTriggered = true
      }
      
    }
    */
    .onChange(of: route.waypoints) { prev, new in
      // Origin Changed
      if (prev.first != new.first) {
        depTriggered = false
      }
      
      // Dest Changed
      if (prev.last != new.last) {
        inbTriggered = false
        atisTriggered = false
        shortInbTriggered = false
        finalTriggered = false
      }
    }
  }
  
}

//#Preview {
//  TabBar()
//}
