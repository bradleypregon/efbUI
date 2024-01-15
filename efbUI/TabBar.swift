//
//  TabBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI

struct TabBar: View {
  @State var selectedTab = 0
  
  var body: some View {
    TabView(selection: $selectedTab) {
      
      AirportScreen()
        .tabItem {
          Label("Airports", systemImage: "airplane.arrival")
        }
        .tag(0)
      
      MapScreen(selectedTab: $selectedTab)
        .ignoresSafeArea(.all)
        .tabItem {
          Label("Map", systemImage: "map")
        }
        .tag(1)
      
      ScratchPadView()
        .tabItem {
          Image(systemName: "square.and.pencil")
          Text("Scratch Pad")
        }
        .tag(2)
      
      SettingsView()
        .tabItem {
          Image(systemName: "gear")
          Text("Settings")
        }
        .tag(3)
    }
  }
}

//#Preview {
//  TabBar()
//}
