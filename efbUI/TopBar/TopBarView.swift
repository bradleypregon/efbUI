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
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime24: String = "00:00z"
  @Environment(SimConnectShipObserver.self) var simConnect
  @State private var serverRunning: Bool = false
  @State var ship: SimConnectShip = .init(coordinate: CLLocationCoordinate2DMake(.zero, .zero), altitude: .zero, heading: .zero, speed: .zero)
  
  var server: ServerListener {
    ServerListener(ship: simConnect)
  }
  
  var body: some View {
    HStack(alignment: .center) {
      Text(currentZuluTime24)
        .padding(.leading, 10)
      
      Toggle("SimConnect", systemImage: serverRunning ? "wifi" : "wifi.slash", isOn: $serverRunning)
        .font(.title2)
        .tint(getServerState())
        .toggleStyle(.button)
        .labelStyle(.iconOnly)
        .contentTransition(.symbolEffect)
        .onChange(of: serverRunning) {
          if serverRunning {
            server.start()
          }
        }
        .padding([.leading, .trailing], 10)
      
      Spacer()
        .frame(width: 20)
      
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
        VStack {
          Text("Heading")
            .font(.caption)
          Text("\(roundToTenths(ship.heading))º")
        }
        .frame(width: 100)
        VStack {
          Text("GPS Alt")
            .font(.caption)
          Text("\(roundToTenths((ship.altitude) * 3.281))'") // meters to feet
        }
        .frame(width: 100)
        VStack {
          Text("Spd (GS)")
            .font(.caption)
          Text("\(roundToTenths((ship.speed) * 1.944))kt") // m/s to knots
        }
        .frame(width: 100)
      }
      .fontWeight(.semibold)
      
      Spacer()
//        TextField("Search Airports...", text: $tempSearchText)
//          .autocorrectionDisabled()
//          .textFieldStyle(.roundedBorder)
//          .frame(width: 350)
//          .onTapGesture {
//            textFieldFocused.toggle()
//          }
//          .popover(isPresented: $textFieldFocused) {
//            Text("Hello there")
//          }
//          .padding(.trailing, 10)
    }
    .padding(.top, 15)
    .onReceive(timer) { _ in
      getCurrentZuluTime24()
    }
    .onReceive(simConnect.ownship) { ship in
      self.ship = ship
    }
  }
  
  func getServerState() -> Color {
    switch ServerStatus.shared.status {
    case .running:
      return .vfr
    case .heartbeat:
      return .mvfr
    case .stopped:
      return .ifr
    }
  }
  
  func getCurrentZuluTime24() {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    let currentDate = Date()
    let zulu = df.string(from: currentDate)
    currentZuluTime24 = "\(zulu)z"
  }
  
  func roundToTenths(_ number: Double) -> String {
    let roundedNumber = number.rounded(toPlaces: 0)
    let nf = NumberFormatter()
    nf.minimumFractionDigits = 0
    nf.maximumFractionDigits = 0
    return nf.string(from: NSNumber(value: roundedNumber)) ?? ""
  }
  
}

//#Preview {
//  TopBarView()
//}

