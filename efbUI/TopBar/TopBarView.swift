//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation
import SwiftData

struct TopBarView: View {
  private let zuluTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var zuluTime: String = "--:--z"
  
  @Environment(SimConnectShipObserver.self) var simConnect
  @State private var serverRunning: Bool = false
  @State private var server: ServerListener?
  
  var body: some View {
    HStack(alignment: .center) {
      Text("\(zuluTime)z")
        .padding(.leading, 10)
        .onReceive(zuluTimer) { _ in
          let df = DateFormatter()
          df.dateFormat = "HH:mm"
          df.timeZone = .gmt
          zuluTime = df.string(from: Date())
        }
      
      Toggle("SimConnect", systemImage: serverRunning ? "wifi" : "wifi.slash", isOn: $serverRunning)
        .font(.title2)
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect)
        .tint(tint(for: server?.status ?? .idle, isOn: serverRunning))
        .padding([.leading, .trailing], 10)
        .onChange(of: serverRunning) { old, new in
          if new && server == nil {
            server = ServerListener(ship: simConnect)
            server?.start()
          } else {
            server?.stop()
            server = nil
          }
        }
      
      Spacer()
        .frame(width: 20)
      
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
        VStack {
          Text("Heading")
          Text("\(Int((simConnect.ownship.value.heading).rounded()))º")
        }
        .frame(width: 100)
        VStack {
          Text("GPS Alt")
          Text("\(Int((simConnect.ownship.value.altitude).rounded()))'")
        }
        .frame(width: 100)
        VStack {
          Text("Spd (GS)")
          Text("\(Int((simConnect.ownship.value.speed).rounded()))kt")
        }
        .frame(width: 100)
      }
      .font(.caption)
      .fontWeight(.semibold)
      
      Spacer()
    }
    .padding(.top, 15)
  }
  
  private func tint(for status: TelemetryStatus, isOn: Bool) -> Color {
    guard isOn else { return .primary }        // toggle is off
    switch status {
    case .idle:        return .primary         // on but idle (or stopped)
    case .connecting:  return .yellow          // connecting
    case .heartbeat:   return .yellow          // heartbeat-only
    case .receiving:   return .vfr             // good/green
    case .error:       return .red             // error state
    }
  }
  
}

//#Preview {
//  TopBarView()
//}

