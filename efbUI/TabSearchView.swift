//
//  TabSearchView.swift
//  efbUI
//
//  Created by Bradley Pregon on 5/12/26.
//
import SwiftUI

struct TabSearchView: View {
  @State private var searchText: String = "asdf"
  
  var body: some View {
    VStack {
      TextField("Search", text: $searchText)
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 8))
      List {
        Text("AIrport")
        Text("VOR")
      }
      .listStyle(.insetGrouped)
    }
  }
}
