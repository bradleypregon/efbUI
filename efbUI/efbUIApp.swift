//
//  efbUIApp.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import GRDB

@main
struct efbUIApp: App {
  @State private var simConnectShip: SimConnectShipObserver = SimConnectShipObserver()
  @State private var simbrief: SimBriefViewModel = SimBriefViewModel()
  @State private var routeManager: RouteManager = RouteManager()
  @State private var appCoordinator: AppCoordinator = AppCoordinator()
  @State private var grdbManager: GRDBManager = GRDBManager()
  
  var body: some Scene {
    WindowGroup {
      TabBar()
        .overlay(alignment: .bottom) {
          StatBarView()
            .frame(width: .infinity, alignment: .leading)
            .padding([.leading, .trailing, .bottom], 18)
            .containerShape(.rect(cornerRadius: 32))
        }
        .environment(simConnectShip)
        .environment(appCoordinator)
        .environment(simbrief)
        .environment(routeManager)
        .environment(grdbManager)
    }
    .modelContainer(for: UserSettings.self)
  }
}

@Observable
final class AppCoordinator {
  var tab: efbTab = .airports
  var selectedICAO: String? = nil // nil for now, default to last selected airport
  
//  var selectedICAO: String? = nil {
//    didSet {
//      if let icao = selectedICAO {
//        Task {
//          await getCharts(for: icao)
//        }
//      }
//    }
//  }
  
  var focusMap: Bool = false
  //var charts: ChartAPISchema? = nil
  
  func openAirport(_ icao: String) {
    selectedICAO = icao
    tab = .airports
  }
  
  func openMap(focusOn icao: String) {
    selectedICAO = icao
    focusMap = true
    tab = .map
  }
  
//  func getCharts(for icao: String) async {
//    do {
//      charts = try await ChartAPI().fetchCharts(icao: icao)
//    } catch let error as ChartAPIError {
//      print(error.localizedDescription)
//    } catch {
//      print("Unexpected error fetching airport charts: \(error)")
//    }
//  }
}
