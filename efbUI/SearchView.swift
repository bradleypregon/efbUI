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
  @Binding var tab: efbTab
  @State private var viewModel = SearchViewModel()
  
  var body: some View {
    NavigationStack {
      Text("TODO: Favorite/common airports here?")
      List(viewModel.airports) { airport in
        HStack {
          Text(airport.airportIdentifier)
          Text(airport.airportName)
          Button {
            print("")
          } label: {
            Text("Map")
          }
        }
      }
      .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#Preview {
  SearchView(tab: .constant(.search))
}
