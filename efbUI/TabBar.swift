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
  }
}

//#Preview {
//  TabBar()
//}
