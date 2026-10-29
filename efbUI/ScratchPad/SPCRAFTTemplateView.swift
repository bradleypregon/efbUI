//
//  ScratchPadCRAFT.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/1/24.
//

import SwiftUI

struct SPCRAFTTemplateView: View {
  @Environment(SimBriefViewModel.self) private var simbrief
  
  let letters: [String] = ["C", "R", "A", "F", "T"]
  
  var body: some View {
    VStack(spacing: 10) {
      ForEach(letters, id: \.self) { letter in
        Card(letter)
      }
    }
    .padding(8)
  }
  
  func Card(_ letter: String) -> some View {
    RoundedRectangle(cornerRadius: 32, style: .continuous)
      .foregroundStyle(Color(.secondarySystemBackground))
      .frame(width: .infinity)
      .overlay(alignment: .leading) {
        Text(letter)
          .font(.system(size: 48))
          .fontWeight(.semibold)
          .padding(.leading, 12)
      }
      .overlay(alignment: .top) {
        let testArr = "KDSM"
        let testRoute = "DSM1 LAWGR BRWRY ARRIVAL1"
        
        if letter == "C" {
          // simbrief.ofp?.origin.icaoCode
          Text(testArr)
            .font(.title)
            .padding(.top, 30)
        }
        if letter == "R" {
          // simbrief.ofp?.general.routeNavigraph
          Text(testRoute)
            .font(.title)
            .padding(.top, 30)
        }
      }
  }
}

#Preview {
  SPCRAFTTemplateView()
    .environment(SimBriefViewModel())
}
