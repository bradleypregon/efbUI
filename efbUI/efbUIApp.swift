//
//  efbUIApp.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
//import SwiftData

@main
struct efbUIApp: App {
  @State private var simConnectShip: SimConnectShipObserver = SimConnectShipObserver()
  // TODO: This no longer needs to be Environment
  @State private var airportDetailViewModel: AirportScreenViewModel = AirportScreenViewModel()
  @State private var simbrief: SimBriefViewModel = SimBriefViewModel()
  @State private var waypointStore: WaypointStore = WaypointStore()
  
  var body: some Scene {
    WindowGroup {
      RootToastView {
        VStack {
          TopBarView()
            .background(.bar)
            .clipShape(
              UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 0)
            )
            .frame(height: 60)
            .padding(.top, 20)
            .ignoresSafeArea(edges: .top)
          TabBar()
            .offset(y: -40)
            .padding(.bottom, -40)
        }
        .environment(simConnectShip)
        .environment(airportDetailViewModel)
        .environment(simbrief)
        .environment(waypointStore)
      }
    }
    .modelContainer(for: UserSettings.self)
  }
}
