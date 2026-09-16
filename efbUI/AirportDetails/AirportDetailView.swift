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
  @State private var searchText: String = ""
  @State private var selectedTab: AirportTab = .Info
  
  var body: some View {
    NavigationSplitView {
      List {
        Section(header: Text("Favorites")) {
          Text("KDSM")
          Text("KDEN")
        }
        Section(header: Text("Recents")) {
          Text("KWhatever")
        }
      }
      .listStyle(.insetGrouped)
      .searchable(text: $searchText)
    } detail: {
      VStack(spacing: 12) {
        
        // Info Section
        VStack {
          SectionHeader(icon: "info.circle", title: "Info")
            .frame(maxWidth: .infinity, alignment: .leading)
          
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
          AirportInfoView()
        case .Weather:
          AirportWeatherView()
        case .Runway:
          AirportRunwayView2()
        default:
          EmptyView()
        }
        
        Spacer()
      }
        .padding()
        .navigationTitle("KDSM")
        .navigationSubtitle("Des Moines Intl Airport")
        .navigationBarTitleDisplayMode(.large)
    }
    .navigationSplitViewStyle(.prominentDetail)
  }
}

struct AirportInfoView: View {
  var body: some View {
    Text("Some mf airport info here")
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
  let icao: String = "KDSM"
  var runways: [RunwayTable] = []
  
  var body: some View {
    ForEach(runways, id: \.id) { rwy in
      
    }
    .task {
      // fetch runways for icao
    }
  }
}

#Preview {
  AirportDetailView()
}
