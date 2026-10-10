//
//  SearchView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/21/24.
//

import SwiftUI

/**
 TODO
 - SearchView results -> make Multi-Type? AirportTable, RunwayTable, etc.
 - LazyVStack -> Some type of grid, make search results a nice card view
 - With Cards, add Favorite Airports at top, Closeset Airport, Home Airport
 */

struct SearchView: View {
  @Environment(GRDBManager.self) private var grdb
  @State private var results: [AirportTable] = []
  @State private var searchText: String = ""
  
  var favorites: [AirportTable] = []
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack {
          ForEach(results) { airport in
            AirportSearchResultCard(airport: airport)
          }
        }
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.large)
      .task(id: searchText) {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
          results = []
          return
        }

        do {
          // debounce
          try await Task.sleep(for: .milliseconds(300))
          results = try await grdb.searchAirports(searchText: query)
        } catch is CancellationError {
          print("The task was cancelled")
        } catch {
          print("GRDB Fetching error: \(error)")
        }
      }
    }
  }
}

struct AirportSearchResultCard: View {
  @Environment(AppCoordinator.self) private var coordinator
  let airport: AirportTable
  
  var body: some View {
    @Bindable var coordinator = coordinator
    HStack(spacing: 10) {
      VStack {
        Text(airport.airportIdentifier)
        Text(airport.airportName ?? "")
      }
      Button {
        coordinator.openAirport(airport.airportIdentifier)
      } label: {
        Text("Details")
      }
      Button {
        coordinator.openMap(focusOn: airport.airportIdentifier)
      } label: {
        Text("Map")
      }
    }
    .padding()
    .background {
      RoundedRectangle(cornerRadius: 8)
        .stroke(.gray, lineWidth: 1)
    }
  }
}

#Preview {
  SearchView()
}
