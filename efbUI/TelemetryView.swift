//
//  TelemetryView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/17/25.
//

import SwiftUI

struct TelemetryView: View {
  var body: some View {
    HStack {
      VStack {
        Text("IAS")
          .font(.subheadline)
        Text("123kt")
          .fontWeight(.semibold)
      }
      .clipShape(Capsule())
      .padding(1)
      
      
      VStack {
        Text("Alt")
          .font(.subheadline)
        Text("36,000ft")
          .fontWeight(.semibold)
      }
      .clipShape(Capsule())
      .padding(1)
      
      Spacer()
    }
  }
}

