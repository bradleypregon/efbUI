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
import SystemConfiguration.CaptiveNetwork

extension String {
  static let userSimbriefID = "userSimbriefID"
  static let userOwnshipRegistration = "userOwnshipRegistration"
  static let userOutboundDistance = "userOutboundDistance"
  static let userAtisDistance = "userAtisDistance"
  static let userInboundDistance = "userInboundDistance"
  static let userShortInboundDistance = "userShortInboundDistance"
  static let userFinalDistance = "userFinalDistance"
}

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  
  @AppStorage(.userSimbriefID) private var simbriefUserID: String = ""
  @AppStorage(.userOwnshipRegistration) private var ownshipRegistration: String = ""
  @AppStorage(.userOutboundDistance) private var outboundDistance: Int = 20
  @AppStorage(.userAtisDistance) private var atisDistance: Int = 40
  @AppStorage(.userInboundDistance) private var inboundDistance: Int = 20
  @AppStorage(.userShortInboundDistance) private var shortInboundDistance: Int = 10
  @AppStorage(.userFinalDistance) private var finalDistance: Int = 5
  
  @State var keepAwake: Bool = false
  
  @State private var calcInput: Int?
  @State private var calcFOutput: Double = .zero
  @State private var calcCOutput: Double = .zero
  
  var numberFormatter: NumberFormatter {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.usesGroupingSeparator = false // Disables thousands commas
    return nf
  }
  
  var body: some View {
    NavigationStack {
      HStack {
        VStack {
          Form {
            Section(header: Text("Map")) {
              HStack {
                Text("Ownship Registration")
                TextField("N123NA", text: $ownshipRegistration)
              }
            }
            Section(header: Text("Simbrief")) {
              HStack {
                Text("SimBrief User ID (numeric)")
                TextField("SimBrief ID (123456)", text: $simbriefUserID)
                  .onChange(of: simbriefUserID) { oldVal, newVal in
                    let filtered = newVal.filter { "0123456789".contains($0) }
                    if filtered != newVal {
                      self.simbriefUserID = filtered
                    }
                  }
              }
            }
            Section(header: Text("Airport Notification Distances (nm)")) {
              HStack {
                Text("Outbound Final Call")
                TextField("20 miles final call...", value: $outboundDistance, format: .number)
                  .keyboardType(.decimalPad)
              }
              HStack {
                Text("Inbound Warning")
                TextField("30 miles inbound...", value: $inboundDistance, format: .number)
                  .keyboardType(.decimalPad)
              }
              HStack {
                Text("ATIS")
                TextField("ATIS for dest...", value: $atisDistance, format: .number)
                  .keyboardType(.decimalPad)
              }
              HStack {
                Text("Short Inbound Warning")
                TextField("10 mile inbound...", value: $shortInboundDistance, format: .number)
                  .keyboardType(.decimalPad)
              }
              HStack {
                Text("Final Warning")
                TextField("5 mile short final...", value: $finalDistance, format: .number)
                  .keyboardType(.decimalPad)
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
        VStack {
          VStack {
            Text("Celsius/Fahrenheit Converter")
            HStack {
              TextField("Celsius/Fahrenheitº", value: $calcInput, format: .number, prompt: Text("C/Fº"))
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
                .onChange(of: calcInput) {
                  if let calc = calcInput {
                    calcFOutput = (Double(calc)*1.8) + 32
                    calcCOutput = (Double(calc)-32) / 1.8
                  }
                }
                .frame(width: 125)
              Text("º")
            }
            
            Text("\(String(format: "%.1f", calcFOutput))ºF")
            Text("\(String(format: "%.1f", calcCOutput))ºC")
          }
          VStack {
            Text("Device IP")
            Text(getDeviceIPAddress())
          }
        }
      }
      
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
    }
  }
  
  func getDeviceIPAddress() -> String {
    var address: String = ""
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        let interface = ptr?.pointee
        let addrFamily = interface?.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) {
          if let name = String(validatingUTF8: interface!.ifa_name), name == "en0" {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(interface!.ifa_addr, socklen_t(interface!.ifa_addr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, socklen_t(0), NI_NUMERICHOST) == 0 {
              address = String(cString: hostname)
            }
          }
        }
        ptr = ptr?.pointee.ifa_next
      }
      freeifaddrs(ifaddr)
    }
    
    return address
  }
}
