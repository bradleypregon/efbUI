//
//  RouteScreen.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/8/24.
//

import SwiftUI
import CoreLocation

struct WaypointContainerButton: View {
  @State private var showPopover: Bool = false
  let wpt: MyWaypoint
  var route: RouteManager
  
  var body: some View {
    Button {
      showPopover.toggle()
    } label: {
      Text(wpt.identifier)
        .padding(8)
        .background(getWaypointColor(wpt.type))
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
    .popover(isPresented: $showPopover) {
      VStack {
        Button("Insert Before") {
          print("Insert before")
        }
        .background(.vfr)
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        Button("Insert After") {
          print("Insert After")
        }
        .background(.mvfr)
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        Button("Remove") {
          remove(wpt)
        }
        .background(.ifr)
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .padding()
    }
  }
  
  func getWaypointColor(_ wpt: WaypointType) -> Color {
    switch wpt {
    case .airport:
      return .blue
    case .navaid:
      return .orange
    case .waypoint:
      return .green
    default:
      return .blue
    }
  }
  
  func remove(_ waypoint: MyWaypoint) {
    route.waypoints.removeAll { $0 == waypoint }
  }
}

struct WaypointsContainer: View {
  @Environment(RouteManager.self) private var routeManager
  @State private var popover: Bool = false
  
  var body: some View {
    List {
      ForEach(routeManager.waypoints) { waypoint in
        WaypointContainerButton(wpt: waypoint, route: routeManager)
      }
      .onMove { from, to in
        routeManager.waypoints.move(fromOffsets: from, toOffset: to)
      }
      .onDelete(perform: removeWaypoint)
    }
  }
  
  func removeWaypoint(at offsets: IndexSet) {
    routeManager.waypoints.remove(atOffsets: offsets)
  }
}

struct CustomInputView: View {
  @Environment(RouteManager.self) private var routeManager
  @State private var currentInput: String = ""
  @State private var modalSheetVisible: Bool = false
  @State var inputResults: [MyWaypoint] = []
  @State private var noWaypointAlertVisible: Bool = false
  
  var body: some View {
    TextField("Wpt...", text: $currentInput)
    // TODO: How to handle airways?
      .onReceive(currentInput.publisher) { val in
        if (val == " ") {
          let res = SQLiteManager.shared.searchTables(query: currentInput.trimmingCharacters(in: .whitespaces).uppercased())
          if res == [] {
            noWaypointAlertVisible = true
            currentInput = ""
            return
          }
          if res.count == 1 {
            guard let temp = res.first else { return }
            routeManager.waypoints.append(temp)
          } else {
            inputResults = res
            modalSheetVisible.toggle()
            currentInput = ""
          }
          currentInput = ""
        }
      }
      .alert("No Waypoint Found", isPresented: $noWaypointAlertVisible) {
        Button {
          noWaypointAlertVisible = false
        } label: {
          Text("Ok (sad!)")
        }
      } message: {
        Text("This some real sad sh!t. No waypoint was found for: \(currentInput)")
      }
      .sheet(isPresented: $modalSheetVisible) {
        List {
          ForEach($inputResults, id: \.id) { $result in
            Button {
              routeManager.waypoints.append(result)
              currentInput = ""
              modalSheetVisible.toggle()
            } label: {
              HStack {
                VStack {
                  Text(result.identifier)
                  Text(result.name)
                }
                VStack {
                  Text("\(result.lat)")
                  Text("\(result.long)")
                }
              }
            }
          }
        }
        .presentationSizing(.form)
      }
      .textFieldStyle(.roundedBorder)
      .frame(maxWidth: 300)
      .autocorrectionDisabled()
      .textInputAutocapitalization(.characters)
  }
}

struct RouteScreen: View {
  @Environment(SimBriefViewModel.self) private var simbrief
  
  var body: some View {
    VStack {
      WaypointsContainer()
      CustomInputView()
    }
    
  }
}

//#Preview {
//  RouteScreen()
//}
