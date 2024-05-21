//
//  efbUIApp.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import SwiftData

@main
struct efbUIApp: App {
  @State private var simConnectShip: SimConnectShipObserver = SimConnectShipObserver()
  @State private var settings: Settings = Settings()
  // TODO: This no longer needs to be Environment
  @State private var airportDetailViewModel: AirportScreenViewModel = AirportScreenViewModel()
  @State private var simbrief: SimBriefViewModel = SimBriefViewModel()
  @State private var waypointStore: WaypointStore = WaypointStore()
  
  var body: some Scene {
    WindowGroup {
      RootToastView {
        ZStack {
          TabBar()
            .frame(maxHeight: .infinity)
            .padding(.top, 65)
          VStack {
            TopBarView()
              .background(.bar)
              .clipShape(RoundedRectangle(cornerRadius: 8))
            Spacer()
          }
        }
        .environment(simConnectShip)
        .environment(settings)
        .environment(airportDetailViewModel)
        .environment(simbrief)
        .environment(waypointStore)
      }
      
    }
    .modelContainer(for: SimBriefUser.self)
  }
}
