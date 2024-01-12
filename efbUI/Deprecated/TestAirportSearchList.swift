//
//  TestAirportSearchList.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/16/23.
//

import SwiftUI

struct TestAirportSearchList: View {
  @State var airportSearchViewModel = AirportDetailViewModel()
  @State var isShowingPopover = false
  
  var body: some View {
    NavigationStack {
      VStack {
        Text("Hello world")
      }
      .navigationTitle("Airports")
      .navigationBarTitleDisplayMode(.large)
      
      .toolbar {
        TextField("Search Airports...", text: $airportSearchViewModel.searchText)
          .textFieldStyle(.roundedBorder)
          .onTapGesture {
            if !isShowingPopover {
              isShowingPopover.toggle()
            }
          }
        .popover(isPresented: $isShowingPopover, content: {
          if airportSearchViewModel.searchText != "" {
            List {
              ForEach(airportSearchViewModel.airportSearchResults) { result in
                Button {
                  _ = SQLiteManager.shared.selectAirport(result.airportIdentifier)
                } label: {
                  Text("\(result.airportIdentifier) - \(result.airportName)")
                }
                .listRowSeparator(.visible)
              }
            }
            .listStyle(.plain)
            .frame(idealWidth: 300, idealHeight: 300, maxHeight: 500)
          }
        })
      }
    }
  }
}

#Preview {
  TestAirportSearchList()
}
