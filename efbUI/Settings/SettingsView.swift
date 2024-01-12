//
//  SettingsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/11/23.
//

import SwiftUI
import MapKit

enum MapStyle: String, CaseIterable {
  case standard = "Standard"
  case mutedStandard = "Muted Standard"
  case satellite = "Satellite"
  case hybrid = "Hybrid"
}

class Settings: ObservableObject {
  @Published var mapStyle: MapStyle = .standard
}

struct SettingsView: View {
  
  @EnvironmentObject var settings: Settings
  
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
          .frame(height: 400)
        Form {
          Section(header: Text("MAP"), content: {
            HStack {
              Text("Map Style")
              Picker("", selection: $settings.mapStyle) {
                ForEach(MapStyle.allCases, id: \.self) { style in
                  Text(style.rawValue).tag(style)
                }
              }
            }
          })
        }
      }
    }
  }
}
