//
//  SimbriefTab.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/6/24.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SimbriefScreen: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(SimBriefViewModel.self) var simbrief
  @Environment(RouteManager.self) var routeManager
  @Query var simbriefID: [UserSettings]
  
  var body: some View {
    VStack {
      if let sbID = simbriefID.first?.simbriefUserID {
        Button {
          Task {
            await simbrief.fetchOFP(for: sbID)
            createRoute(navlog: simbrief.ofp?.navlog ?? [])
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
          SimbriefDetails(ofp: ofp)
        } else if let errorMessage = simbrief.sbAPIErrorMessage {
          Text(errorMessage)
        }
      }
      else {
        ContentUnavailableView("Simbrief Unvailable", systemImage: "airplane.circle", description: Text("Enter Simbrief ID in Settings tab to pull data."))
      }
      
    }
  }
  
  func createRoute(navlog: [OFPNavlog]) {
    guard !navlog.isEmpty else { return }
    // query database
    for nav in navlog {
      guard let lat = Double(nav.lat), let long = Double(nav.long) else { return }
      let waypoint: MyWaypoint = .init(lat: lat, long: long, type: .gps, name: nav.name)
      routeManager.waypoints.append(waypoint)
    }
  }
}

struct SimbriefDetails: View {
  let ofp: OFPSchema
  
  enum SimbriefScreenPickerOptions: String, Identifiable, CaseIterable {
    case dep = "Depature"
    case arr = "Arrival"
    case alt = "Alternate"
    case route = "Route"
    
    var id: Self { self }
  }
  
  @State private var selectedSimbriefPicker: SimbriefScreenPickerOptions = .dep
  
  var body: some View {
    Text("\(ofp.origin.icaoCode)/\(ofp.origin.planRwy) \(ofp.general.routeNavigraph) \(ofp.destination.icaoCode)/\(ofp.destination.planRwy) | \(ofp.alternate?.first?.icaoCode ?? "")/\(ofp.alternate?.first?.planRwy ?? "")")
    
    VStack {
      HStack {
        Text(ofp.aircraft.icaoCode)
        Text(ofp.general.airline + ofp.general.flightNumber)
          .fontWeight(.semibold)
        Text(ofp.aircraft.reg)
      }
      HStack {
        HStack {
          VStack {
            Text("CI:")
            Text("FL:")
          }
          .frame(alignment: .leading)
          VStack {
            Text(ofp.general.costIndex)
            Text(ofp.general.initialAltitude)
          }
          .frame(alignment: .trailing)
        }
        Divider()
        HStack {
          VStack {
            Text("Dep:")
            Text("Arr:")
            Text("ETE:")
          }
          .frame(alignment: .leading)
          VStack {
            Text(convertDate(ofp.times.schedDep) + "z")
            Text(convertDate(ofp.times.schedArr) + "z")
            Text(ofp.times.ete)
          }
          .frame(alignment: .trailing)
        }
        Divider()
        HStack {
          VStack {
            Text("Pax:")
            Text("Cargo:")
            Text("Block:")
          }
          .frame(alignment: .leading)
          VStack {
            Text(ofp.weights.paxCountActual)
            Text(ofp.weights.cargo)
            Text(ofp.fuel.block)
          }
          .frame(alignment: .trailing)
        }
        Divider()
        HStack {
          VStack {
            Text("eZFW:")
            Text("eTOW:")
            Text("eLDW:")
          }
          .frame(alignment: .leading)
          VStack {
            Text(ofp.weights.estZFW)
            Text(ofp.weights.estTOW)
            Text(ofp.weights.estLDW)
          }
          .frame(alignment: .trailing)
        }
      }
      .frame(maxHeight: 50)
    }
    
    Picker("Airport", selection: $selectedSimbriefPicker) {
      ForEach(SimbriefScreenPickerOptions.allCases, id: \.id) { tab in
        Text(tab.rawValue)
          .tag(tab)
      }
    }
    .pickerStyle(.segmented)
    
    switch selectedSimbriefPicker {
    case .dep:
      SimbriefTabDetails(airport: ofp.origin)
    case .arr:
      SimbriefTabDetails(airport: ofp.destination)
    case .alt:
      SimbriefTabDetails(alternates: ofp.alternate)
    case .route:
      SimbriefTabRoute(route: ofp.navlog)
    }
  }
  
  func convertDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    return df.string(from: date)
  }
}

// For development
//@MainActor
//let previewContainer: ModelContainer = {
//  let container = try! ModelContainer(for: UserSettings.self, configurations: .init(isStoredInMemoryOnly: true))
//  container.mainContext.insert(UserSettings(simbriefUserID: "405981"))
//  return container
//}()
//
//#Preview {
//  SimbriefScreen()
//    .modelContainer(previewContainer)
//}

