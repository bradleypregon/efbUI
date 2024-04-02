//
//  SettingsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/11/23.
//

import SwiftUI
import MapKit
import Observation
import SwiftData

enum MapStyle: String, CaseIterable {
  case standard = "Standard"
  case mutedStandard = "Muted Standard"
  case satellite = "Satellite"
  case hybrid = "Hybrid"
}

@Observable
class Settings {
  
}

struct SettingsView: View {
  @Environment(Settings.self) private var settings
  @Environment(\.modelContext) private var modelContext
  
  @State var mapStyle: MapStyle = .standard
  
  @State var simbriefUserIDString: String = ""
  @State var mapOwnshipRegistration: String = ""
  @State var outboundNotificationDistance: Int = 20
  @State var inboundNotificationDistance: Int = 30
  @State var finalNotificationDistance: Int = 5
  
  @Query var simbriefUser: [SimBriefUser]
  
  var body: some View {
    
    NavigationStack {
      VStack {
        Form {
          Section(header: Text("Map"), content: {
            HStack {
              Text("Map Style")
              Picker("Map Style", selection: $mapStyle) {
                ForEach(MapStyle.allCases, id: \.self) { style in
                  Text(style.rawValue).tag(style)
                }
              }
              
            }
            HStack {
              Text("Default Ownship Registration")
              TextField("N123NA", text: $mapOwnshipRegistration)
            }
          })
          Section(header: Text("Simbrief")) {
            HStack {
              Text("SimBrief User ID")
              TextField("SimBrief ID (123456)", text: $simbriefUserIDString)
                .onSubmit {
                  if simbriefUser.isEmpty {
                    // new
                    let user = SimBriefUser(userID: simbriefUserIDString)
                    modelContext.insert(user)
                  } else {
                    // edit
                    simbriefUser.first?.userID = simbriefUserIDString
                  }
                }
            }
          }
          Section(header: Text("Airport Notification Distances")) {
            HStack {
              Text("Outbound")
              TextField("20 miles final call...", value: $outboundNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
            }
            HStack {
              Text("Inbound")
              TextField("30 miles inb...", value: $inboundNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
            }
            HStack {
              Text("Final")
              TextField("5 mile final...", value: $finalNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
            }
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
    .onAppear {
      simbriefUserIDString = simbriefUser.first?.userID ?? ""
    }
  }
}
