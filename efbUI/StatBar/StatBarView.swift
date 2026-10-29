//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation
import SwiftData

struct StatBarView: View {
  @Environment(SimConnectShipObserver.self) var simConnect
  @Environment(ScratchPadManager.self) private var padManager
  @Environment(AppCoordinator.self) private var appCoord
  
  @State private var serverRunning: Bool = false
  @State private var server: ServerListener?
  @State private var telemetryVisible: Bool = false
  
  private let utcFormat: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(abbreviation: "UTC")
    return df
  }()
  
  var body: some View {
    @Bindable var coord = appCoord
    @Bindable var pad = padManager
    
    HStack(spacing: 12) {
      TimelineView(.periodic(from: .now, by: 1.0)) { ctx in
        Text(utcFormat.string(from: ctx.date))
          .padding(.leading, 10)
          .fontWeight(.semibold)
      }
      
      Toggle("Drawing", systemImage: pad.isOpen ? "scribble.variable" : "scribble", isOn: $pad.isOpen)
        .font(.title2)
        .tint(pad.isOpen ? .primary : .secondary)
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect)
        .glassEffect()
      
      Toggle("SimConnect", systemImage: serverRunning ? "wifi" : "wifi.slash", isOn: $serverRunning)
        .glassEffect()
        .tint(server?.status.color)
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect)
        .onChange(of: serverRunning) { old, new in
          if new && server == nil {
            server = ServerListener(ship: simConnect)
            server?.start()
            telemetryVisible = true
          } else {
            server?.stop()
            server = nil
          }
        }
      
      Toggle("Telemetry", systemImage: "gauge.with.needle", isOn: $telemetryVisible)
        .glassEffect()
        .tint(.lapis)
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect)
        .onTapGesture {
          telemetryVisible.toggle()
        }
      
      if telemetryVisible {
        ScrollView(.horizontal) {
          HStack(spacing: 12) {
            headingButton()
            altitudeButton()
            speedButton()
          }
          .containerShape(.rect(cornerRadius: 32))
        }
        .font(.caption)
        .fontWeight(.semibold)
      }
      
      Spacer()
    }
    .padding()
    .frame(alignment: .center)
  }
  
  func headingButton() -> some View {
    @State var isTapped: Bool = false
    
    return (
      Button {
        isTapped.toggle()
      } label: {
        VStack {
          Text("Heading")
          Text("\(Int(simConnect.ownship.heading.rounded()))º")
            .font(.title3)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
      }
        .buttonStyle(.glass)
        .popover(isPresented: $isTapped) {
          Text("Change units to TRUE/MAG")
            .padding()
            .frame(minWidth: 200, minHeight: 100)
        }
    )
  }
  
  func altitudeButton() -> some View {
    @State var isTapped: Bool = false
    
    return (
      Button {
        isTapped.toggle()
      } label: {
        VStack {
          Text("Altitude (GPS)")
          Text("\(Int(simConnect.ownship.altitude.rounded()))º")
            .font(.title3)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
      }
        .buttonStyle(.glass)
        .popover(isPresented: $isTapped) {
          Text("Change units to FEET/METERS")
            .padding()
            .frame(minWidth: 200, minHeight: 100)
        }
    )
  }
  
  func speedButton() -> some View {
    @State var isTapped: Bool = false
    
    return (
      Button {
        isTapped.toggle()
      } label: {
        VStack {
          Text("Speed (GS)")
          Text("\(Int(simConnect.ownship.speed.rounded()))º")
            .font(.title3)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
      }
        .buttonStyle(.glass)
        .popover(isPresented: $isTapped) {
          Text("Change units to GS/IAS")
            .padding()
            .frame(minWidth: 200, minHeight: 100)
        }
    )
  }
  
}

#Preview {
  StatBarView()
    .environment(SimConnectShipObserver())
    .frame(width: .infinity, alignment: .leading)
    .padding([.leading, .trailing], 12)
    .containerShape(.rect(cornerRadius: 32))
}
