//
//  TabBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import CoreLocation
import Combine

struct TabBar: View {
  @State var selectedTab = 0
  @Environment(SimConnectShipObserver.self) private var ship
  @Environment(SimBriefViewModel.self) private var simbrief
  
  @State private var depNoticeTriggered: Bool = false
  @State private var inboundTriggered: Bool = false
  @State private var tenMileInbd: Bool = false
  @State private var fiveMileInbd: Bool = false
  
  let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
  
  var body: some View {
    TabView(selection: $selectedTab) {
      
      AirportScreen(selectedTab: $selectedTab)
        .tabItem {
          Label("Airports", systemImage: "scope")
        }
        .tag(0)
      
      SimbriefScreen()
        .tabItem {
          Label("Simbrief", systemImage: "list.bullet.clipboard")
        }
        .tag(1)
      
      ChartsView(selectedTab: $selectedTab)
        .tabItem {
          Label("Charts", systemImage: "doc.on.doc")
        }
        .tag(2)
      
      MapScreen(selectedTab: $selectedTab)
        .ignoresSafeArea(.all)
        .tabItem {
          Label("Map", systemImage: "map")
        }
        .tag(3)
      
      ScratchPadView()
        .tabItem {
          Label("Scratch Pad", systemImage:"square.and.pencil")
        }
        .tag(4)
      
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
        .tag(5)
    }
    .onReceive(timer) { _ in
      
      guard let ship = ship.ship else { return }
      
      if let ofp = simbrief.ofp {
        let shipLocation = CLLocation(latitude: ship.coordinate.latitude, longitude: ship.coordinate.longitude)
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
}

//#Preview {
//  TabBar()
//}
