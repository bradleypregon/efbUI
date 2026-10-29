//
//  AirportDetailView.swift
//  efbUI
//
//  Created by Bradley Pregon on 9/9/26.
//

import SwiftUI

enum WeatherType: String, CaseIterable, Identifiable {
  case METAR, ATIS, TAF
  var id: Self { self }
}

enum AirportTab: String, CaseIterable, Identifiable {
  case Info, Weather, Runway, Procedure, NOTAM
  var id: Self { self }
}

struct SectionHeader: View {
  var icon: String
  var title: String
  
  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: icon)
      Text(title)
    }
    .padding()
    .font(.title2)
    .fontWeight(.semibold)
  }
}

struct WeatherDetailCard: View {
  let item: WeatherItem
  
  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        Image(systemName: item.icon)
          .font(.title3.weight(.semibold))
        Text(item.type)
          .font(.headline)
          .fontWeight(.semibold)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(item.value)
        .font(.largeTitle.weight(.semibold))
        .frame(maxWidth: .infinity, alignment: .leading)
        .minimumScaleFactor(0.8)
        .lineLimit(1)
      
      Text(item.sub)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding()
    .frame(width: 175)
    .background(.thinMaterial)
    .clipShape(.rect(cornerRadius: 32, style: .continuous))
    .task {
      // Fetch weather (TODO: Cached weather)
    }
  }
}

struct WeatherItem: Identifiable {
  let id: String = UUID().uuidString
  let icon: String
  let type: String
  let value: String
  let sub: String
}

struct AirportDetailView: View {
  @Environment(AppCoordinator.self) private var coordinator
  @Environment(GRDBManager.self) private var grdbMan
  
  @AppStorage("homeAirportICAO") private var homeICAO: String = "KDSM"
  @AppStorage("lastAirportICAO") private var lastICAO: String = "KDEN"
  
  @State private var selectedTab: AirportTab = .Info
  @State private var airport: AirportTable?
  @State private var runways: [RunwayTable] = []
  
  private var startupICAO: String? {
    if !lastICAO.isEmpty { return lastICAO }
    if !homeICAO.isEmpty { return homeICAO }
    return nil
  }
  
  var body: some View {
    if let airport {
      // Move to struct or view
      VStack(spacing: 12) {
        // Info
        VStack {
          SectionHeader(icon: "info.circle", title: airport.airportIdentifier)
            .frame(maxWidth: .infinity, alignment: .leading)
          
          // Grid?
          Text("Sunrise, Sunset, Coordinates, Elevation")
        }
        .padding()
        .background(.thinMaterial)
        .containerShape(.rect(cornerRadius: 32, style: .continuous))
        
        Picker("AirportTab", selection: $selectedTab) {
          ForEach(AirportTab.allCases) { type in
            Text(type.rawValue)
          }
        }
        .pickerStyle(.segmented)
        
        switch selectedTab {
        case .Info:
          AirportInfoView(airport: airport, runways: runways)
        case .Weather:
          AirportWeatherView()
        case .Runway:
          AirportRunwayView(icao: airport.airportIdentifier, runways: runways)
        default:
          EmptyView()
        }
        
        Spacer()
      }
      .padding()
    } else {
      ContentUnavailableView {
        Label("No Airport Selected", systemImage: "airplane.circle")
      } description: {
        Text("Search for an airport, or set a home airport in Settings.")
      } actions: {
        Button("Search Airports") { /* show search */ }
        Button("Import SimBrief") { /* ... */ }
      }
      .task(id: coordinator.selectedICAO) {
        guard let icao = coordinator.selectedICAO, !icao.isEmpty else { return }
        await fetchAirportData(icao: icao)
      }
    }
  }
  
  private func fetchAirportData(icao: String) async {
    do {
      airport = try await grdbMan.fetchAirport(by: icao)
      runways = try await grdbMan.fetchRunways(for: icao)
      
      lastICAO = icao
      if airport != nil { lastICAO = icao }
    } catch {
      print("Error fetching airport data: \(error)")
      airport = nil
      runways = []
    }
  }
}

#Preview {
  AirportDetailView()
    .environment(AppCoordinator())
    .environment(GRDBManager())
}
