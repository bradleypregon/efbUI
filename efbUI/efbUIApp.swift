//
//  efbUIApp.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI

@main
struct efbUIApp: App {
  @StateObject var simConnect = SimConnect()
  let settings = Settings()
  
  var body: some Scene {
    WindowGroup {
      
      VStack {
        TopBarView()
          .background(.bar)
        TabBar()
      }
      .environmentObject(simConnect)
      .environmentObject(settings)
      
    }
  }
}
