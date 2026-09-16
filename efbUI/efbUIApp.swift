//
//  efbUIApp.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
//import SwiftData

@main
struct efbUIApp: App {
  @State private var simConnectShip: SimConnectShipObserver = SimConnectShipObserver()
  @State private var simbrief: SimBriefViewModel = SimBriefViewModel()
  @State private var routeManager: RouteManager = RouteManager()
  @State private var appCoordinator: AppCoordinator = AppCoordinator()
  
  var body: some Scene {
    WindowGroup {
      
      VStack {
        TabBar()
        TopBarView()
          .clipShape(
            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 0)
          )
          .frame(height: 50)
          .background(.bar)
      }
      .environment(simConnectShip)
      .environment(appCoordinator)
      .environment(simbrief)
      .environment(routeManager)
    }
    .modelContainer(for: UserSettings.self)
  }
}

@Observable
final class AppCoordinator {
  var tab: efbTab = .airports
  var selectedICAO: String? = nil {
    didSet {
      if let icao = selectedICAO {
        Task {
          await getCharts(for: icao)
        }
      }
    }
  }
  var focusMap: Bool = false
  var charts: ChartAPISchema? = nil
  
  func openAirport(_ icao: String) {
    selectedICAO = icao
    tab = .airports
  }
  
  func openMap(focusOn icao: String) {
    selectedICAO = icao
    focusMap = true
    tab = .map
  }
  
  func getCharts(for icao: String) async {
    do {
      charts = try await ChartAPI().fetchCharts(icao: icao)
    } catch let error as ChartAPIError {
      print(error.localizedDescription)
    } catch {
      print("Unexpected error fetching airport charts: \(error)")
    }
  }
}
