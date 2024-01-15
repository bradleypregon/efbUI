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
  @State private var currentZuluTime24: String = ""
  @State private var currentTime: String = ""
  @Environment(SimConnect.self) var simConnect
  
  @State private var dragOffset: CGFloat = 40
  @State private var expanded: Bool = false
  
  @Query var simbriefUser: [SimBriefUser]
  
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
            HStack {
              Text("Simbrief ID: \(simbriefID)")
              Button {
                let simbriefAPI = SimBriefAPI()
                simbriefAPI.fetchLastFlightPlan(for: simbriefID)
              } label: {
                Text("Fetch SimBrief Route")
              }
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
                dragOffset = 40
                expanded = false
              }
            }
          }
      )
    }
    .frame(height: dragOffset, alignment: .top)
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
