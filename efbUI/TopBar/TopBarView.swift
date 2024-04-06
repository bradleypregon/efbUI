//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation
import SwiftData
//import AVFoundation

// Linked list
// Each node can be an airport, vor, navaid, departure, arrival, any type of navigation aid with a coordinate
// upon simbrief api fetch, compile route and load it into LinkedList

// Typical route format:
// head -> Airport
// nodes -> each route component
// tail -> Airport


// TODO: Instead of a heterogeneous list, create a custom type, and when the database is queried, just create custom object from what is returned from db
@Observable
class WaypointStore {
  var waypoints: [Waypoint] = []
}

struct Waypoint: Identifiable, Hashable {
  let id: String = UUID().uuidString
  let name: String
}

// TODO: Add Move and Delete functions like a normal vertical SwiftUI List
struct WaypointsContainer: View {
  @Environment(WaypointStore.self) private var waypointStore
  @State private var popover: Bool = false
  
  var body: some View {
//      Ideal, but need Horizontal
//      List {
//        ForEach(waypointStore.waypoints) { waypoint in
//          WptView(wpt: waypoint)
//        }
//        .onMove(perform: move)
//      }
    //
    WrappingHStack(models: waypointStore.waypoints) { waypoint in
      WptView(wpt: waypoint)
    }
  }
  
  func WptView(wpt: Waypoint) -> some View {
    Button {
      print(wpt)
    } label: {
      Text(wpt.name)
        .padding(8)
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
    .popover(isPresented: $popover) {
      Button {
        remove(wpt)
      } label: {
        Text("Remove")
      }
    }
    .onLongPressGesture {
      popover.toggle()
    }
  }
  
  func remove(_ waypoint: Waypoint) {
    waypointStore.waypoints.removeAll { $0 == waypoint }
  }
  
  func move(from source: IndexSet, to destination: Int) {
    waypointStore.waypoints.move(fromOffsets: source, toOffset: destination)
  }
}

struct CustomInputView: View {
  @Environment(WaypointStore.self) private var waypointStore
  @State private var currentInput: String = ""
  
  var body: some View {
    TextField("Wpt...", text: $currentInput)
      // TODO: Query each db table (Airport, NBD, VOR) upon submission and return either an array or single object
      // airports, enroute_airways, enroute_waypoints, pathpoints, sids, stars, terminal_waypoints, vhfnavaids
      // TODO: How to handle airways?
      // If an array is returned, its probbaly a matching name, user needs to select appropriate
      // For instance, there are multiple VORs (or NBDs?) that have the same 3 letter identifier. Need to pick the right one
    .onReceive(currentInput.publisher) { val in
      if (val == " ") {
        let wpt = Waypoint(name: currentInput.trimmingCharacters(in: .whitespaces))
        waypointStore.waypoints.append(wpt)
        currentInput = ""
      }
    }
    .textFieldStyle(.roundedBorder)
    .frame(maxWidth: 300)
    .autocorrectionDisabled()
    .textInputAutocapitalization(.characters)
  }
}

struct TopBarView: View {
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime24: String = ""
  @State private var currentTime: String = ""
  @Environment(SimConnectShipObserver.self) var simConnect
  @Environment(SimBriefViewModel.self) var simbrief
  @Environment(WaypointStore.self) var waypointStore
  @State private var serverRunning: Bool = false
  
  let topOffset: CGFloat = 65
  let middleOffset: CGFloat = 300
  let bottomOffset: CGFloat = 600
  @State private var dragOffset: CGSize = .zero
  @State private var position: CGFloat = 65
  @State private var halfExpanded: Bool = false
  @State private var fullExpanded: Bool = false
  
  var server: ServerListener {
    ServerListener(ship: simConnect)
  }
  
  var body: some View {
    VStack {
      HStack(alignment: .center, spacing: 20) {
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
          .padding([.leading, .trailing], 20)
        
        Spacer()
          .frame(width: 40)
        
        HStack {
          VStack {
            Text("Heading")
              .font(.caption)
            Text("\(roundToTenths(simConnect.ownship.heading))º")
          }
          VStack {
            Text("GPS Altitude")
              .font(.caption)
            Text("\(roundToTenths((simConnect.ownship.altitude) * 3.281))'") // meters to feet
          }
          VStack {
            Text("Speed")
              .font(.caption)
            Text("\(roundToTenths((simConnect.ownship.speed) * 1.944))kt") // m/s to knots
          }
        }
        .fontWeight(.semibold)
        
        // i do not know why i wanted to do this
        //        Button {
        //          let utter = AVSpeechUtterance(string: "hello world")
        //          utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        //          utter.rate = 0.5
        //
        //          speechSynth.speak(utter)
        //        } label: {
        //          Text("Speech")
        //        }
        //        .buttonStyle(.bordered)
        
        Spacer()
        Text(currentZuluTime24)
        Spacer()
      }
      .padding([.top], 15)
      Spacer()
      
      if halfExpanded {
        if let ofp = simbrief.ofp {
          // TODO: build array from ofp including origin, waypoints, destination
          // TODO: Color for Airports, color for Departures, color for Arrivals, color for TOC/TOD
          WrappingHStack(models: ofp.navlog.filter { $0.type != "apt" }) { wpt in
            Button {
              print("\(wpt.ident) tapped")
            } label: {
              Text(wpt.isSidStar == "1" && wpt.ident != "TOC" && wpt.ident != "TOD" ? "\(wpt.via).\(wpt.ident)" : wpt.ident)
                .padding(8)
                .background(wpt.ident == "TOC" || wpt.ident == "TOD" ? Color.green : Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .font(.caption)
            }
          }
          .frame(maxWidth: 600, maxHeight: 400)
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      
      // Full -> OFP
      if fullExpanded {
        VStack {
          WaypointsContainer()
          CustomInputView()
        }
        .padding()
      }
      
      Spacer()
      VStack {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: 200, height: 8)
          .foregroundStyle(.gray)
      }
      .padding(18) // are these working or is it placebo?
      .padding(-18)
      .offset(x: 0, y: -10)
      .gesture(
        DragGesture()
          .onChanged { self.dragOffset = $0.translation }
          .onEnded { value in
            withAnimation {
              // bar is at top (40)
              if self.position == topOffset {
                
                // minimal change -> snap to top
                if value.translation.height < 0 && value.translation.height < 50 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
                
                //                   pulled down a little -> middle
                else if value.translation.height >= 50 && value.translation.height <= 100 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pulled a lot -> bottom
                else if value.translation.height > 100 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
              }
              
              // bar is at middle (300)
              else if self.position == middleOffset {
                // minimal change -> snap to middle
                if value.translation.height > -50 && value.translation.height < 50 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pushed a little -> top
                else if value.translation.height <= -50 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
                
                // pulled a little -> bottom
                else if value.translation.height >= 50 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
              }
              
              // bar is at bottom (500)
              else {
                // minimal change -> snap to bottom
                if value.translation.height > 0 && value.translation.height > -50 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
                
                // pushed up slightly -> middle
                else if value.translation.height <= -50 && value.translation.height <= -100 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pushed up enough -> top
                else if value.translation.height < -100 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
              }
              
              self.dragOffset = .zero
            }
          }
      )
    }
    .frame(height: dragOffset.height + position)
    .onReceive(timer) { _ in
      getCurrentZuluTime24()
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

