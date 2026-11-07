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

@Model
class Reminder {
  var id: Int
  var label: String
  var subLabel: String
  var distance: Int
  
  init(id: Int, label: String = "", subLabel: String = "", distance: Int = 20) {
    self.id = id
    self.label = label
    self.subLabel = subLabel
    self.distance = distance
  }
}

struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Reminder.id) var reminders: [Reminder]
  
  @AppStorage(.userSimbriefID) private var simbriefUserID: String = ""
  @AppStorage(.userOwnshipRegistration) private var ownshipRegistration: String = ""
  @AppStorage(.userNotificationsEnabled) private var notisEnabled: Bool = true
  @AppStorage(.distanceListSeedRequired) private var seedRequired: Bool = true
  
  @State var keepAwake: Bool = false
  
  @State private var calcInput: Int?
  @State private var calcOutput: (Double, Double) = (0, 0) // (F,C)
  
  @State private var distanceNotificationsExpanded: Bool = false
  
  @State private var ipRevealed: Bool = false
  
  var numberFormatter: NumberFormatter {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.usesGroupingSeparator = false // Disables thousands commas
    return nf
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
            GridRow {
              Text("Ownship Reg")
                .fontWeight(.semibold)
              TextField("N123NA", text: $ownshipRegistration)
            }
            Divider()
            GridRow {
              Text("Simbrief ID")
                .fontWeight(.semibold)
              TextField("SimBrief ID (123456)", text: $simbriefUserID)
                .onChange(of: simbriefUserID) { _, newVal in
                  validateInput(for: newVal)
                }
              Button {
                print("Launch Browser & Simbrief")
              } label: {
                Image(systemName: "arrow.up.forward.square")
                  .tint(.primary)
              }
              .buttonStyle(.glass)
            }
            Divider()
            GridRow {
              Text("Device IP")
                .fontWeight(.semibold)
              TextField("DeviceIP", text: .constant(getDeviceIPAddress()))
                .disabled(true)
                .blur(radius: ipRevealed ? 0 : 6)
                .animation(.easeInOut, value: ipRevealed)
                .contentShape(Rectangle())
                .onTapGesture {
                  ipRevealed.toggle()
                }
              Button {
                print("Copy IP")
              } label: {
                Image(systemName: "document.on.document")
                  .font(.system(size: 16))
                  .tint(.primary)
              }
              .buttonStyle(.glass)
            }
          }
        } header: {
          Text("Flight")
        }
        
        Section {
          Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
              Text("Cº/Fº Converter")
                .fontWeight(.semibold)
              TextField("Celsius/Fahrenheitº", value: $calcInput, format: .number, prompt: Text("C/Fº"))
                .keyboardType(.decimalPad)
                .onChange(of: calcInput) {
                  calcTemp(for: calcInput)
                }
            }
            HStack {
              Text("\(String(format: "%.1f", calcOutput.0))ºF")
                .padding()
                .glassEffect()
              Text("\(String(format: "%.1f", calcOutput.1))ºC")
                .padding()
                .glassEffect()
            }
            .fontWeight(.semibold)
          }
          
          
        } header: {
          Text("Tools")
        }
        
        Section {
          Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
              Text("Keep Device Awake")
                .fontWeight(.semibold)
              Spacer()
              Toggle("", isOn: $keepAwake)
                .onChange(of: keepAwake) {
                  UIApplication.shared.isIdleTimerDisabled = keepAwake
                }
            }
            GridRow {
              Text("Enable Distance Notifications")
                .fontWeight(.semibold)
              Spacer()
              Toggle("", isOn: $notisEnabled)
            }
          }
        } header: {
          Text("Preferences")
        }
        
        Section {
          DisclosureGroup(isExpanded: $distanceNotificationsExpanded) {
            List {
              ForEach(reminders) { reminder in
                Text(reminder.label)
              }
            }
          } label: {
            Text("Expand to Modify")
              .fontWeight(.semibold)
          }
        } header: {
          Text("Flight Notification Distances (nm)")
        }
      }
      .onAppear {
        if seedRequired {
          addInitialItems()
          seedRequired = false
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
  
  func validateInput(for input: String) {
    let filtered = input.filter { "0123456789".contains($0) }
    if filtered != input {
      self.simbriefUserID = filtered
    }
  }
  
  func calcTemp(for temp: Int?) {
    guard let temp = temp else { return }
    let F = (Double(temp)*1.8) + 32
    let C = (Double(temp)-32) / 1.8
    calcOutput = (F,C)
  }
  
  func addInitialItems() {
    let items: [Reminder] = [
      .init(id: 1, label: "Outbound", subLabel: "Final Call", distance: 10),
      .init(id: 2, label: "Inbound", subLabel: "Initial Call", distance: 20),
      .init(id: 3, label: "ATIS", subLabel: "", distance: 40),
      .init(id: 4, label: "Inbound Call", subLabel: "", distance: 10),
      .init(id: 5, label: "Final", subLabel: "Approach Call", distance: 5)
    ]
    for item in items {
      modelContext.insert(item)
    }
  }
}

#Preview {
  let mock: UserDefaults = {
    let store = UserDefaults(suiteName: "settings_preview")!
    store.set("", forKey: .userSimbriefID)
    store.set("", forKey: .userOwnshipRegistration)
    store.set(true, forKey: .userNotificationsEnabled)
    store.set(true, forKey: .distanceListSeedRequired)
    return store
  }()
  
  SettingsView()
    .defaultAppStorage(mock)
    .modelContainer(for: Reminder.self)
}
