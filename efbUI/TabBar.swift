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
      
      ChartsView(selectedTab: $selectedTab)
        .tabItem {
          Label("Charts", systemImage: "doc.on.doc")
        }
        .tag(1)
      
      MapScreen(selectedTab: $selectedTab)
        .ignoresSafeArea(.all)
        .tabItem {
          Label("Map", systemImage: "map")
        }
        .tag(2)
      
      ScratchPadView()
        .tabItem {
          Label("Scratch Pad", systemImage:"square.and.pencil")
        }
        .tag(3)
      
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
        .tag(4)
    }
  }
}

//#Preview {
//  TabBar()
//}
