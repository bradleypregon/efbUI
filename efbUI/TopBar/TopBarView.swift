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
            .font(.caption)
          Text("\(roundToTenths(simConnect.ownship.value.heading))º")
        }
        .frame(width: 100)
        VStack {
          Text("GPS Alt")
            .font(.caption)
          Text("\(roundToTenths((simConnect.ownship.value.altitude) * 3.281))'") // meters to feet
        }
        .frame(width: 100)
        VStack {
          Text("Spd (GS)")
            .font(.caption)
          Text("\(roundToTenths((simConnect.ownship.value.speed) * 1.944))kt") // m/s to knots
        }
        .frame(width: 100)
      }
      .fontWeight(.semibold)
      
      Spacer()
    }
    .padding(.top, 15)
  }
  
  func roundToTenths(_ number: Double) -> String {
    let roundedNumber = number.rounded(toPlaces: 0)
    let nf = NumberFormatter()
    nf.minimumFractionDigits = 0
    nf.maximumFractionDigits = 0
    return nf.string(from: NSNumber(value: roundedNumber)) ?? ""
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

