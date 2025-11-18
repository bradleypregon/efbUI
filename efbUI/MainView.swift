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

struct MainView: View {
  @State private var selectedTab: SelectedTab = .none
  @State private var detailPanelVisible: Bool = false
  @State private var notePadVisible: Bool = false
  
  // Main Options
  @State private var routeVisible: Bool = false
  @State private var weatherVisible: Bool = false
  @State private var telemetryVisible: Bool = false
  @State private var pinboardVisible: Bool = false
  
  @State private var test: Bool = false
  
  // Sidebar
  private let detailPanelWidth: CGFloat = 250
  @State private var detailPanelVisibleWidth: CGFloat = 0
  
  var body: some View {
    HStack(spacing: 0) {
      // Tab Bar
      TabBarView(detailPanelVisible: $detailPanelVisible, notePadVisible: $notePadVisible)
        .zIndex(3)
      
      ZStack(alignment: .leading) {
        // Map control view can interface with mapviewmodel
        
        VStack {
          ZStack {
            MapView()
            
            GeometryReader { geometry in
              MainOptionsView(
                routeVisible: $routeVisible,
                weatherVisible: $weatherVisible,
                telemetryVisible: $telemetryVisible,
                pinboardVisible: $pinboardVisible
              )
              .padding(.leading, 12)
              .animation(.easeInOut, value: detailPanelVisibleWidth)
              .zIndex(2)
            }
            
            if test {
              Color.blue.opacity(0.75)
                .border(.red, width: 2)
            }
          }
          
          // Weather
          if weatherVisible {
            WeatherView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
          
          // Pin Board
          if pinboardVisible {
            PinboardView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
          
          // Telemetry
          if telemetryVisible {
            TelemetryView()
              .frame(width: .infinity, height: 25)
              .background(.black)
          }
        }
        .padding(.leading, detailPanelVisibleWidth)
        .animation(.easeInOut, value: detailPanelVisibleWidth)
        
        
        
        // Tab Bar Detail View
        if detailPanelVisible {
          DetailPanelView(detailPanelVisible: $detailPanelVisible)
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
    .onChange(of: detailPanelVisible) {
      detailPanelVisible ? (detailPanelVisibleWidth = 250) : (detailPanelVisibleWidth = 0)
    }
    .overlay(alignment: .trailing) {
      NotePadView(isVisible: $notePadVisible)
        .padding(16)
        .allowsHitTesting(true)
        .zIndex(1000)
    }
  }
}

#Preview {
  MainView()
}
