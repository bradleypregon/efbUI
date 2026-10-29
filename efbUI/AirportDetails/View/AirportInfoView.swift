//
//  AirportInfoView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/27/26.
//

import SwiftUI

struct AirportInfoView: View {
  let airport: AirportTable
  let runways: [RunwayTable]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Some airport info here")
      
      DiagramView(runways: runways)
        .frame(width: 400, height: 400)
        .padding()
      
    }
    .frame(width: .infinity)
  }
}

#Preview {
  AirportInfoView(airport: .mock, runways: [])
}
