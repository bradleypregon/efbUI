//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation

struct TopBarView: View {
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime: String = ""
  @State private var currentTime: String = ""
  @EnvironmentObject var simConnect: SimConnect
  
  var body: some View {
    HStack {
      Spacer()
      
      Text("Connect:")
      Button {
        let server = SimConnectServer(simConnect: simConnect)
        try! server.start()
      } label: {
        Image(systemName: "target")
      }
      .frame(width: 40, height: 40, alignment: .center)
      .font(.title)
      
//      Spacer()
//      Text("Hdg: \(String(format: "%.1f", simConnect.gpsEvent?.heading ?? 0.0))")
//      Text("Alt: \(String(format: "%.1f", simConnect.gpsEvent?.altitude ?? 0.0))")
//
//      Text("Spd: \(String(format: "%.0f", simConnect.gpsEvent?.speed ?? 0.0))")
      Text("Hdg: \(String(format: "%.1f", simConnect.simConnectShip?.heading ?? .zero))")
      Text("Alt: \(String(format: "%.1f", simConnect.simConnectShip?.altitude ?? .zero))")
      Text("Spd: \(String(format: "%.0f", simConnect.simConnectShip?.speed ?? .zero))")
      Spacer()
      Text(currentTime)
      Text(currentZuluTime)
      Spacer()
      Spacer()
    }
    .onReceive(timer) { _ in
      getCurrentZuluTime()
      getCurrentTime()
    }
  }
  
  func getCurrentZuluTime() {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    let currentDate = Date()
    let zulu = df.string(from: currentDate)
    currentZuluTime = "Zulu: \(zulu)z"
  }
  
  func getCurrentTime() {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    let currentDate = df.string(from: Date())
    currentTime = "Current: \(currentDate)"
  }
  
}

//#Preview {
//  TopBarView()
//}
