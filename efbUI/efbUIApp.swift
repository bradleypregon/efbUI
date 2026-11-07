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
  @State private var coordinator: AppCoordinator = AppCoordinator()
  @State private var grdbManager: GRDBManager = GRDBManager()
  @State private var toastManager: ToastManager = ToastManager()
  @State private var scratchPadManager: ScratchPadManager = ScratchPadManager()
  
  var body: some Scene {
    WindowGroup {
      VStack {
        TabBar()
          .overlay(alignment: .topLeading) {
            ToastsView(toasts: $toastManager.toasts)
          }
        StatBarView()
          .background(.lapis)
      }
      .environment(simConnectShip)
      .environment(coordinator)
      .environment(simbrief)
      .environment(routeManager)
      .environment(grdbManager)
      .environment(toastManager)
      .environment(scratchPadManager)
      .task {
        // Restore last ICAO
        if let last = UserDefaults.standard.string(forKey: .lastIcao), !last.isEmpty {
          coordinator.icao = last
          coordinator.tab = .airports
        }
      }
    }
    .modelContainer(for: Reminder.self)
  }
}

@Observable
final class AppCoordinator {
  var tab: efbTab = .airports
  
  var icao: String = "" {
    didSet {
      // Update AppStorage when changed
      print(icao)
      if !icao.isEmpty { UserDefaults.standard.set(icao, forKey: .lastIcao) }
    }
  }
  
  var focusMap: Bool = false
  
  func openAirport(_ icao: String) {
    self.icao = icao
    tab = .airports
  }
  
  func openMap(focusOn icao: String) {
    self.icao = icao
    focusMap = true
    tab = .map
  }
  
  // TODO: Move
  //  var selectedICAO: String? = nil {
  //    didSet {
  //      if let icao = selectedICAO {
  //        Task {
  //          await getCharts(for: icao)
  //        }
  //      }
  //    }
  //  }
  //var charts: ChartAPISchema? = nil
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
