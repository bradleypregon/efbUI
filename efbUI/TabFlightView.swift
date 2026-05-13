//
//  TabFlightView.swift
//  efbUI
//
//  Created by Bradley Pregon on 5/12/26.
//
import SwiftUI

struct TabFlightView: View {
  @Environment(SimBriefViewModel.self) var simbrief
  
  var body: some View {
    Text("Some flight info here")
    Button {
      Task {
        await simbrief.fetchOFP(for: "405981")
        // TODO: Create route from simbrief
        //createRoute(navlog: simbrief.ofp?.navlog ?? [])
      }
      
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
      Text("Fetch SimBrief")
    }
    .padding()
    .background(.blue)
    .foregroundStyle(.white)
    .fontWeight(.semibold)
    .clipShape(Capsule())
    
    if let ofp = simbrief.ofp {
      Text("Origin: \(ofp.origin.icaoCode)")
      Text("Dest: \(ofp.destination.icaoCode)")
      Text("Plane: \(ofp.aircraft.name)")
    }
  }
}
