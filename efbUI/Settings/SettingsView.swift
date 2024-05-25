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

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query var userSettings: [UserSettings]
  
  @State var ownshipRegistration: String = ""
  @State var simbriefUserIDString: String = ""
  @State var outboundNotificationDistance: Int = 20
  @State var inboundNotificationDistance: Int = 30
  @State var finalNotificationDistance: Int = 5
  @State var keepAwake: Bool = false
  
  var body: some View {
    NavigationStack {
      VStack {
        Form {
          Section(header: Text("Map")) {
            HStack {
              Text("Ownship Registration")
              TextField("N123NA", text: $ownshipRegistration)
                .onSubmit {
                  if userSettings.isEmpty {
                    let settings = UserSettings(ownshipRegistration: ownshipRegistration)
                    modelContext.insert(settings)
                  } else {
                    userSettings.first?.ownshipRegistration = ownshipRegistration
                  }
                }
            }
          }
          Section(header: Text("Simbrief")) {
            HStack {
              Text("SimBrief User ID")
              TextField("SimBrief ID (123456)", text: $simbriefUserIDString)
                .onSubmit {
                  userSettings.first?.simbriefUserID = simbriefUserIDString
                  if userSettings.isEmpty {
                    let settings = UserSettings(simbriefUserID: simbriefUserIDString)
                    modelContext.insert(settings)
                  } else {
                    userSettings.first?.simbriefUserID = simbriefUserIDString
                  }
                }
            }
          }
          Section(header: Text("Airport Notification Distances")) {
            HStack {
              Text("Outbound")
              TextField("20 miles final call...", value: $outboundNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
                .onSubmit {
                  userSettings.first?.outboundDistance = outboundNotificationDistance
                }
            }
            HStack {
              Text("Inbound")
              TextField("30 miles inb...", value: $inboundNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
                .onSubmit {
                  userSettings.first?.inboundDistance = inboundNotificationDistance
                }
            }
            HStack {
              Text("Final")
              TextField("5 mile final...", value: $finalNotificationDistance, format: .number)
                .keyboardType(.decimalPad)
                .onSubmit {
                  userSettings.first?.finalDistance = finalNotificationDistance
                }
            }
          }
          
          Section {
            HStack {
              Toggle("Keep Awake", systemImage: keepAwake ? "bolt.fill" : "bolt.slash", isOn: $keepAwake)
                .font(.title2)
                .toggleStyle(.button)
                .contentTransition(.symbolEffect)
                .onChange(of: keepAwake) {
                  UIApplication.shared.isIdleTimerDisabled = keepAwake
                }
            }
          } header: {
            Text("Misc Settings")
          }

        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
    .onAppear {
      ownshipRegistration = userSettings.first?.ownshipRegistration ?? ""
      simbriefUserIDString = userSettings.first?.simbriefUserID ?? ""
      outboundNotificationDistance = userSettings.first?.outboundDistance ?? 20
      inboundNotificationDistance = userSettings.first?.inboundDistance ?? 20
      finalNotificationDistance = userSettings.first?.finalDistance ?? 5
    }
  }
}
