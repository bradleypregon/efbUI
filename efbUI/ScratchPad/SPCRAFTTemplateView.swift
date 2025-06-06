//
//  ScratchPadCRAFT.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/1/24.
//

import SwiftUI
import SwiftData

struct SPCRAFTTemplateView: View {
  @Environment(SimBriefViewModel.self) private var simbrief
  
  struct Item: Identifiable, Hashable {
    let letter: String
    let desc: String
    var id: Self { self }
  }
  
  let items: [Item] = [
    Item(letter: "C", desc: "Clear To"),
    Item(letter: "R", desc: "Route"),
    Item(letter: "A", desc: "Altitudes"),
    Item(letter: "F", desc: "Frequency"),
    Item(letter: "T", desc: "Transponder"),
  ]
  
  var body: some View {
    VStack(spacing: 10) {
      ForEach(items) { item in
        Card(letter: item.letter, desc: item.desc)
      }
    }
    .padding(8)
  }
  
  func Card(letter: String, desc: String) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundStyle(.secondary)
      HStack {
        VStack(alignment: .leading) {
          Text(letter)
//            .foregroundStyle(.secondary)
            .font(.system(size: 45))
            .fontWeight(.semibold)
          Text(desc)
            .font(.caption)
            .fontWeight(.light)
        }
        
        
        if letter == "C", let arrival = simbrief.ofp?.origin.icaoCode {
          VStack {
            Text(arrival)
              .font(.title2)
              .fontDesign(.rounded)
            Spacer()
          }
          .padding(.leading, 50)
          .padding(.top, 20)
        }
        if letter == "R", let route = simbrief.ofp?.general.routeNavigraph {
          VStack {
            Text(route)
              .font(.title2)
              .fontDesign(.rounded)
            Spacer()
          }
          .padding(.leading, 50)
          .padding(.top, 20)
        }
        Spacer()
      }
      .padding()
    }
    .frame(maxHeight: .infinity)
  }
}

#Preview {
  SPCRAFTTemplateView()
}
