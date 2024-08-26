//
//  SimbriefTab.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/6/24.
//

import SwiftUI
import SwiftData

struct SimbriefScreen: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(SimBriefViewModel.self) var simbrief
  @Query var simbriefID: [UserSettings]
  
  enum SimbriefScreenPickerOptions: String, Identifiable, CaseIterable {
    case dep = "Depature"
    case arr = "Arrival"
    case alt = "Alternate"
    
    var id: Self { self }
  }
  
  @State private var selectedSimbriefPicker: SimbriefScreenPickerOptions = .dep
  
  var body: some View {
    VStack {
      if let sbID = simbriefID.first?.simbriefUserID {
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
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
        .fontWeight(.semibold)
        .clipShape(Capsule())
        
        if let temp = simbrief.ofp {
          Text("\(temp.origin.icaoCode)/\(temp.origin.planRwy) \(temp.general.routeNavigraph) \(temp.destination.icaoCode)/\(temp.destination.planRwy) | \(temp.alternate?.first?.icaoCode ?? "")/\(temp.alternate?.first?.planRwy ?? "")")
          
          VStack {
            HStack {
              Text(temp.aircraft.icaoCode)
              Text(temp.general.airline + temp.general.flightNumber)
                .fontWeight(.semibold)
              Text(temp.aircraft.reg)
            }
            HStack {
              HStack {
                VStack {
                  Text("CI:")
                  Text("FL:")
                }
                .frame(alignment: .leading)
                VStack {
                  Text(temp.general.costIndex)
                  Text(temp.general.initialAltitude)
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
                  Text(convertDate(temp.times.schedDep) + "z")
                  Text(convertDate(temp.times.schedArr) + "z")
                  Text(temp.times.ete)
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
                  Text(temp.weights.paxCountActual)
                  Text(temp.weights.cargo)
                  Text(temp.fuel.block)
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
                  Text(temp.weights.estZFW)
                  Text(temp.weights.estTOW)
                  Text(temp.weights.estLDW)
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
            SimbriefTabDetails(airport: temp.origin)
          case .arr:
            SimbriefTabDetails(airport: temp.destination)
          case .alt:
            SimbriefTabDetails(alternates: temp.alternate)
          }
          
        }
      }
      else {
        ContentUnavailableView("Simbrief Unvailable", systemImage: "airplane.circle", description: Text("Enter Simbrief ID in Settings tab to pull data."))
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


// For development
@MainActor
let previewContainer: ModelContainer = {
  let container = try! ModelContainer(for: UserSettings.self, configurations: .init(isStoredInMemoryOnly: true))
  container.mainContext.insert(UserSettings(simbriefUserID: "405981"))
  return container
}()

#Preview {
  SimbriefScreen()
    .environmentObject(SimBriefViewModel())
    .modelContainer(previewContainer)
}

