//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation
import SwiftData

// Linked list
// Each node can be an airport, vor, navaid, departure, arrival, any type of navigation aid with a coordinate
// upon simbrief api fetch, compile route and load it into LinkedList

// Typical route format:
// head -> Airport
// nodes -> each route component
// tail -> Airport

class LinkedList {
  var head: Node?
  
  func append(value: Any) {
    let newNode = Node(value: value)
    
    if head == nil {
      head = newNode
    } else {
      var current = head
      while current?.next != nil {
        current = current?.next
      }
      current?.next = newNode
    }
  }
  
  func printList() {
    var current = head
    while current != nil {
      if current?.next != nil {
        print(current!.value, terminator: " -> ")
      } else {
        print(current!.value)
      }
      current = current?.next
    }
  }
}

class Node {
  var value: Any
  var next: Node?
  
  init(value: Any) {
    self.value = value
  }
}

struct TopBarView: View {
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime24: String = ""
  @State private var currentTime: String = ""
  @Environment(SimConnectShipObserver.self) var simConnect
  @Environment(SimBriefViewModel.self) var simbriefViewModel
  
  let topOffset: CGFloat = 65
  let middleOffset: CGFloat = 300
  let bottomOffset: CGFloat = 600
  
  @State private var dragOffset: CGSize = .zero
  @State private var position: CGFloat = 65
  @State private var halfExpanded: Bool = false
  @State private var fullExpanded: Bool = false
  
  @Query var simbriefUser: [SimBriefUser]
  @State var route: String = ""
  
  var simConnectListener: SimConnectListener = SimConnectListener()
  
  //  @State private var flightPlan: OFPSchema? = nil
  
  var body: some View {
    VStack {
      HStack(alignment: .center) {
        Spacer()
        Button {
          // TODO: Instantiate server once. Don't keep reinstantiating
          var server = SimConnectServer(simConnect: simConnect, simConnListener: simConnectListener)
          if !server.isRunning {
            do {
              try server.start()
            } catch {
              print("Error trying to start SimConnect server: \(error)")
            }
          } else {
            server.stop()
          }
        } label: {
          Image(systemName: "target")
            .frame(width: 25, height: 25, alignment: .center)
            .font(.title)
            .foregroundStyle(getServerState())
        }
        
        Spacer()
          .frame(width: 40)
        HStack(spacing: 20) {
          VStack {
            Text("Heading")
              .font(.caption)
            Text(roundToTenths(simConnect.ship?.heading ?? .zero))
          }
          VStack {
            Text("GPS Altitude")
              .font(.caption)
            Text(roundToTenths(simConnect.ship?.altitude ?? .zero))
          }
          VStack {
            Text("Speed")
              .font(.caption)
            Text(roundToTenths(simConnect.ship?.altitude ?? .zero))
          }
        }
        Spacer()
        Text(currentZuluTime24)
        Spacer()
      }
      .padding([.top], 15)
      Spacer()
      
      // Half -> ATIS, general Sim Brief details
      if halfExpanded {
        VStack {
          if let simbriefID = simbriefUser.first?.userID {
            HStack {
              Text("SimBrief OFP | \(simbriefID)")
              Button {
                simbriefViewModel.fetchOFP(for: simbriefID)
                
                // TODO: Process split variable -> Construct linked list with each route component
                // TODO: Check airac and compare to current downloaded database
                
                // Query: Airports, Enroute (Airways, NBD Navaids, Waypoints, VHF Navaids)
                // Give error feedback if waypoint not found
                // HOW TO: Multiple waypoints in world can have same name - how to differentiate?
                
                //                  let tempSplit = route.split(separator: " ")
                //                  let linkedList = LinkedList()
                //                  for item in tempSplit {
                //                    linkedList.append(value: String(item))
                //                  }
                //                  linkedList.printList()
              } label: {
                Text("Fetch Route")
              }
            }
            
            if let temp = simbriefViewModel.ofp {
              Text("\(temp.origin.icaoCode)/\(temp.origin.planRwy) \(temp.general.routeNavigraph) \(temp.destination.icaoCode)/\(temp.destination.planRwy) | \(temp.alternate?.first?.icaoCode ?? "")/\(temp.alternate?.first?.planRwy ?? "")")
              HStack {
                ScrollView(.vertical) {
                  if let atis = temp.origin.atis {
                    ForEach(atis, id:\.self) { ati in
                      Text(ati.network)
                      Text(ati.message)
                      Divider()
                    }
                  }
                }
                VStack {
                  Text(temp.general.airline + temp.general.flightNumber)
                  Text(temp.aircraft.reg)
                  Text("CI: \(temp.general.costIndex)")
                  Text("FL: \(temp.general.initialAltitude)")
                  Text("ETE: \(temp.times.ete)")
                  Text("Dep: \(convertDate(temp.times.schedDep))z")
                  Text("Arr: \(convertDate(temp.times.schedArr))z")
                }
                VStack {
                  Text(temp.aircraft.icaoCode)
                  Text("Pax: \(temp.weights.paxCountActual)")
                  Text("Cargo: \(temp.weights.cargo)")
                  Text("Block: \(temp.fuel.block)")
                  Text("eZFW: \(temp.weights.estZFW)")
                  Text("eTOW: \(temp.weights.estTOW)")
                  Text("eLDW: \(temp.weights.estLDW)")
                }
                ScrollView(.vertical) {
                  if let atis = temp.destination.atis {
                    ForEach(atis, id:\.self) { ati in
                      Text(ati.network)
                      Text(ati.message)
                      Divider()
                    }
                  }
                }
              }
              
            }
          }
          
        }
      }
      
      // Full -> OFP
      if fullExpanded {
        Text("perhaps another view here")
      }
      
      Spacer()
      VStack {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: 200, height: 8)
          .foregroundStyle(.gray)
      }
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
    switch simConnectListener.serverState {
    case .connected:
      return .green
    case .heartbeat:
      return .blue
    case .stopped:
      return .red
    }
  }
  
  func convertDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    return df.string(from: date)
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
