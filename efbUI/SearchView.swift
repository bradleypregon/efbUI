//
//  SearchView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/21/24.
//

import SwiftUI

struct SearchView: View {
  @Binding var tab: efbTab
  @State var searchText: String = ""
  
  var body: some View {
    NavigationStack {
      List(1...10, id: \.self) { item in
        HStack {
          Text("Thing \(item)")
          Button {
            print("")
          } label: {
            Text("Map")
          }
        }
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
      .navigationTitle("Search")
      .navigationBarTitleDisplayMode(.large)
    }
  }
}

#Preview {
  SearchView(tab: .constant(.search))
}
