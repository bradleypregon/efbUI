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
  var mapStyle: MapStyle = .standard
  
  var simBriefUID: String = ""
}

struct SettingsView: View {
  
  @Environment(Settings.self) private var settings
  @Environment(\.modelContext) private var modelContext
  
  @State var simbriefUserIDString: String = ""
  
//  var simbriefUser: SimBriefUser?
  @Query var simbriefUser: [SimBriefUser]
  
  var body: some View {
    NavigationStack {
      VStack {
        Spacer()
          .frame(height: 400)
        Form {
          Section(header: Text("Map"), content: {
            HStack {
              Text("Map Style")
//              Picker("", selection: settings.mapStyle.rawValue) {
//                ForEach(MapStyle.allCases, id: \.self) { style in
//                  Text(style.rawValue).tag(style)
//                }
//              }
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
        }
      }
    }
    .onAppear {
      simbriefUserIDString = simbriefUser.first?.userID ?? ""
    }
  }
}
