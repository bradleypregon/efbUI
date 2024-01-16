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

class LinkedList<T> {
  var head: Node<T>?
  
  func append(value: T) {
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

class Node<T> {
  var value: T
  var next: Node?
  
  init(value: T) {
    self.value = value
  }
}

struct TopBarView: View {
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime24: String = ""
  @State private var currentTime: String = ""
  @Environment(SimConnect.self) var simConnect
  
  @State private var dragOffset: CGFloat = 40
  @State private var expanded: Bool = false
  
  @Query var simbriefUser: [SimBriefUser]
  @State var route: String = ""
  
  /*
   @State var dragOffset: CGFloat = 40
   @State var expanded: Bool = false
   var body: some View {
    VStack {
      HStack {
        // a small bit of content here at the top
      }
   
      if expanded {
        // more content here when the view is expanded
      }
   
      VStack {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: 200, height: 5)
      }
      .offset(x: 0, y: -5)
      .gesture(
        DragGesture()
          .onChanged { value in
            dragOffset = value.translation.height
          }
          .onEnded { _ in
            withAnimation {
              if dragOffset > 75 {
                dragOffset = 300
                expanded = true
              }
              else {
                dragOffset = 0
                expanded = false
              }
            }
          }
        )
    }
    .frame(height: dragOffset)
   }
   
   */
  var body: some View {
    VStack {
      HStack {
        Spacer()
        
        Text("Connect:")
        Button {
          let server = SimConnectServer(simConnect: simConnect)
          
          do {
            try server.start()
          } catch let error {
            print("Error trying to start SimConnect server: \(error)")
          }
        } label: {
          Image(systemName: "target")
            .frame(width: 25, height: 25, alignment: .center)
            .font(.title)
        }
        
        Spacer()
          .frame(width: 40)
        Text("Hdg: \(simConnect.simConnectShip?.heading.string ?? "")")
        Text("Alt: \(simConnect.simConnectShip?.altitude.string ?? "")")
        Text("Spd: \(simConnect.simConnectShip?.speed.string ?? "")")
        Spacer()
        Text(currentZuluTime24)
        Spacer()
      }
//      .fixedSize(horizontal: false, vertical: true)
      Spacer()
      // hidden content here
      if expanded {
        VStack {
          if let simbriefID = simbriefUser.first?.userID {
            Text("SimBrief OFP")
            HStack {
              VStack {
                Text("SimBrief ID")
                Text(simbriefID)
              }
              Button {
                let simbriefAPI = SimBriefAPI()
                simbriefAPI.fetchLastFlightPlan(for: simbriefID) { ofp in
                  route = "\(ofp.origin.icaoCode) \(ofp.general.routeNavigraph) \(ofp.destination.icaoCode)"
                  let tempSplit = route.split(separator: " ")
                  let linkedList = LinkedList<String>()
                  for item in tempSplit {
                    linkedList.append(value: String(item))
                  }
                  linkedList.printList()
                }
              } label: {
                Text("Fetch Route")
              }
              
              Text(route)
            }
          }
          
        }
      }
      Spacer()
      VStack {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: 200, height: 5)
          .foregroundStyle(.gray)
      }
      .offset(x: 0, y: -5)
      .onTapGesture {
        withAnimation {
          if !expanded {
            dragOffset = 300
            expanded = true
          } else {
            dragOffset = 40
            expanded = false
          }
        }
      }
      // MARK: TODO
      // TODO: Fix drag gesture. Pulling down works ok, pushing up is funky
//      .gesture(
//        DragGesture()
//          .onChanged { value in
//            dragOffset = value.translation.height
//          }
//          .onEnded { _ in
//            withAnimation {
//              if dragOffset > 75 {
//                dragOffset = 300
//                expanded = true
//              }
//              else {
//                dragOffset = 40
//                expanded = false
//              }
//            }
//          }
//      )
    }
    .frame(height: dragOffset)
    .onReceive(timer) { _ in
      getCurrentZuluTime24()
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
  
}

#Preview {
  TopBarView()
}
