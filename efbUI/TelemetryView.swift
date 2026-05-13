//
//  TelemetryView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/17/25.
//

import SwiftUI

struct TelemetryView: View {
  @Environment(SimConnectShipObserver.self) var ship
  
  var body: some View {
    HStack {
      VStack {
        Text("IAS")
          .font(.subheadline)
        Text("\(ship.ownship.value.speed)kt")
          .fontWeight(.semibold)
      }
      .clipShape(Capsule())
      .padding(1)
      
      
      VStack {
        Text("ALT")
          .font(.subheadline)
        Text("\(ship.ownship.value.altitude)ft")
          .fontWeight(.semibold)
      }
      .clipShape(Capsule())
      .padding(1)
      
      Spacer()
    }
  }
}

