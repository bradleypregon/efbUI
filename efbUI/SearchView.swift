//
//  SearchView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/21/24.
//

import SwiftUI
import Observation
import Combine

@MainActor
@Observable final class SearchViewModel {
  var airports: [AirportTable] = []
  
  var searchTask: Task<Void, Never>?
  var searchTextSubject = CurrentValueSubject<String, Never>("")
  var cancellables: Set<AnyCancellable> = []
  
  var requestMap: Bool = false
  
  init() {
    searchTextSubject
      .filter { $0.isEmpty }
      .sink { _ in
        self.searchTask?.cancel()
        self.airports = []
      }
      .store(in: &cancellables)
    
    searchTextSubject
      .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
      .filter { !$0.isEmpty }
      .sink { [weak self] text in
        guard let self else { return }
        self.searchTask?.cancel()
        self.searchTask = createSearchTask(text)
      }
      .store(in: &cancellables)
  }
  
  func createSearchTask(_ text: String) -> Task<Void, Never> {
    Task { @MainActor in
      airports = await SQLiteManager.shared.queryAirportsAsync(text)
    }
  }
  
  var searchText: String = "" {
    didSet {
      searchTextSubject.send(searchText)
    }
  }
}

struct SearchView: View {
  @State private var viewModel = SearchViewModel()
  
  let columns = [GridItem(.adaptive(minimum: 250))]
  
  var body: some View {
    NavigationStack {
      Text("TODO: Favorite/common airports here?")
      ScrollView {
        LazyVGrid(columns: columns) {
          ForEach(viewModel.airports) { airport in
            AirportSearchResultCard(airport: airport)
          }
        }
      }
      .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.large)
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
        Text(airport.airportName)
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
