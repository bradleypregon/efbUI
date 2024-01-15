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
  @State private var simConnect: SimConnect = SimConnect()
  @State private var settings: Settings = Settings()
  
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
    }
    .modelContainer(for: SimBriefUser.self)
  }
}
