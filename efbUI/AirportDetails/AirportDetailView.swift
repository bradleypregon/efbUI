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
  
  @State private var selectedTab: AirportTab = .Info
  @State private var airport: AirportTable? = AirportTable.mock
  @State private var runways: [RunwayTable] = []
  
  var body: some View {
    VStack(spacing: 12) {
      // Info
      VStack {
        SectionHeader(icon: "info.circle", title: airport?.airportIdentifier ?? "Info")
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
        AirportRunwayView2(runways: runways)
      default:
        EmptyView()
      }
      
      Spacer()
    }
    .padding()
    .task {
      if coordinator.selectedICAO == "" {
        airport = AirportTable.mock
        coordinator.selectedICAO = airport?.airportIdentifier
      }
      await fetchAirportData()
    }
  }
  
  // doing too much. split per view. RunwayView -> task to fetch runways
  private func fetchAirportData() async {
    guard let icao = coordinator.selectedICAO else { return }
    do {
      async let airportFetch = grdbMan.fetchAirport(by: icao)
      async let runwaysFetch = grdbMan.fetchRunways(for: icao)
      
      airport = try await airportFetch
      runways = try await runwaysFetch
    } catch {
      print("Error fetching airport data: \(error)")
      runways = []
      airport = nil
    }
  }
}

struct AirportInfoView: View {
  let airport: AirportTable?
  let runways: [RunwayTable]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Some airport info here")
      
      DiagramView(runways: RunwayTable.mockKDSM)
        .frame(width: 400, height: 400)
        .padding()
      
    }
    .frame(width: .infinity)
  }
}

struct AirportWeatherView: View {
  let weatherItems: [WeatherItem] = [
    .init(icon: "wind", type: "Wind", value: "20", sub: "knot"),
    .init(icon: "eye", type: "Visibility", value: "10+", sub: "nautical mile"),
    .init(icon: "cloud", type: "Clouds", value: "25%", sub:"5000ft"),
    .init(icon: "thermometer.variable", type: "Temp", value: "30", sub: "c | 50 f"),
    .init(icon: "gauge.with.dots.needle.50percent", type: "Altimeter", value: "29.92", sub: "inHg | 1012mh?")
  ]
  
  @State private var selectedWeatherType: WeatherType = .METAR
  
  var body: some View {
    VStack {
      Text("`METAR KLAX 152153Z 23013G21KT 10SM FEW020 26/16 A2990 RMK AO2 SLP122 T02610156 $`")
        .padding()
        .background(.thickMaterial)
      
      ScrollView(.horizontal) {
        LazyHStack(spacing: 12) {
          ForEach(weatherItems) { item in
            WeatherDetailCard(item: item)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
    .containerShape(.rect(cornerRadius: 32, style: .continuous))
  }
}

struct AirportRunwayView2: View {
  let runways: [RunwayTable]
  
  var body: some View {
    ForEach(runways, id: \.id) { rwy in
      Text(rwy.runwayIdentifier)
    }
  }
}

#Preview {
  AirportDetailView()
    .environment(AppCoordinator())
    .environment(GRDBManager())
}
