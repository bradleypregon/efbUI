//
//  SimbriefTab.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/6/24.
//

import SwiftUI
import SwiftData

struct SimbriefScreen: View {
  @Environment(SimBriefViewModel.self) var simbrief
  @Query var simbriefID: [UserSettings]
  
  var body: some View {
    VStack {
      if let sbID = simbriefID.first?.simbriefUserID {
        HStack {
          Text("SimBrief OFP | \(sbID)")
          Button {
            simbrief.fetchOFP(for: sbID)
            
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
        
        if let temp = simbrief.ofp {
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
  
  func convertDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    return df.string(from: date)
  }
  
}

#Preview {
  SimbriefScreen()
}
