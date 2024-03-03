//
//  ScratchPadCRAFT.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/1/24.
//

import SwiftUI

struct ScratchPadCRAFT: View {
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
        .fill(Color.Neumorphic.main).softOuterShadow(offset: 2, radius: 2)
      HStack {
        VStack(alignment: .leading) {
          Text(letter)
            .foregroundStyle(Color.Neumorphic.secondary)
            .font(.system(size: 45))
            .fontWeight(.semibold)
          Text(desc)
            .font(.caption)
            .fontWeight(.light)
        }
        Spacer()
      }
      .padding()
    }
    .frame(maxHeight: .infinity)
  }
}

#Preview {
  ScratchPadCRAFT()
}
