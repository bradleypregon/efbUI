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
  @State private var simConnect: SimConnectShips = SimConnectShips()
  @State private var settings: Settings = Settings()
  @State private var airportDetailViewModel: AirportDetailViewModel = AirportDetailViewModel()
  
  var body: some Scene {
    WindowGroup {
      ZStack {
        TabBar()
          .frame(maxHeight: .infinity)
          .padding(.top, 50)
        VStack {
          TopBarView()
            .background(.bar)
          Spacer()
        }
      }
      .environment(simConnect)
      .environment(settings)
      .environment(airportDetailViewModel)
    }
    .modelContainer(for: SimBriefUser.self)
  }
}
