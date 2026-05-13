//
//  MainView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/31/25.
//

import SwiftUI

enum SelectedTab {
  case none, search, flight, airports, settings
}

@Observable
class MainViewModel {
  var selectedTab: SelectedTab = .none
  var detailPanelVisible: Bool = false
  var notePadVisible: Bool = false
  
  var telemetryVisible: Bool = false
  var pinboardVisible: Bool = false
}

struct MainView: View {
  @Environment(SimConnectShipObserver.self) var ship
  @State var mainVM = MainViewModel()
  @State var mapViewModel = MapScreenViewModel()
  
  // Main Options
  @State private var routeVisible: Bool = false
  @State private var weatherVisible: Bool = false
  
  // Sidebar vars
  private let detailPanelWidth: CGFloat = 300
  @State private var detailPanelVisibleWidth: CGFloat = 0
  
  var body: some View {
    HStack(spacing: 0) {
      // Tab Bar
      TabBarView(detailPanelVisible: $mainVM.detailPanelVisible, notePadVisible: $mainVM.notePadVisible, selectedTab: $mainVM.selectedTab)
        .zIndex(3)
      
      // Main Content
      ZStack(alignment: .leading) {
        // Gets pushed over when detailPanelVisible is true
        VStack {
          ZStack {
            MapView(mapViewModel: mapViewModel)
            
            GeometryReader { geometry in
              MainOptionsView(
                routeVisible: $routeVisible,
                weatherVisible: $weatherVisible,
                telemetryVisible: $mainVM.telemetryVisible,
                pinboardVisible: $mainVM.pinboardVisible,
                mapViewModel: $mapViewModel
              )
              .padding(.leading, 12)
              .animation(.easeInOut, value: detailPanelVisibleWidth)
              .zIndex(2)
            }
          }
          
          // Weather
          if weatherVisible {
            WeatherView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
          
          // Pin Board
          if mainVM.pinboardVisible {
            PinboardView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
          
          // Telemetry
          if mainVM.telemetryVisible {
            TelemetryView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
        }
        .padding(.leading, detailPanelVisibleWidth)
        .animation(.easeInOut, value: detailPanelVisibleWidth)
        
        // Tab Bar Detail View
        // Displays over previous VStack
        if mainVM.detailPanelVisible {
          DetailPanelView(selectedTab: $mainVM.selectedTab, detailPanelVisible: $mainVM.detailPanelVisible)
            .padding()
            .frame(width: detailPanelWidth, alignment: .topLeading)
            .frame(height: .infinity)
            .background(.lapis)
            .transition(.move(edge: .leading))
            .shadow(radius: 8)
            .zIndex(4)
        }
        
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    .onChange(of: mainVM.detailPanelVisible) {
      mainVM.detailPanelVisible ? (detailPanelVisibleWidth = 250) : (detailPanelVisibleWidth = 0)
    }
    .overlay(alignment: .trailing) {
      NotePadView(isVisible: $mainVM.notePadVisible)
        .padding(16)
        .allowsHitTesting(true)
        .zIndex(1000)
    }
  }
}

#Preview {
  MainView()
}
