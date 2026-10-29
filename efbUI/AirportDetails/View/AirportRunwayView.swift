//
//  AirportRunwayView2.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/27/26.
//

import SwiftUI

struct AirportRunwayView: View {
  let icao: String
  let runways: [RunwayTable]
  
  var body: some View {
    ForEach(runways, id: \.id) { rwy in
      Text(rwy.runwayIdentifier)
    }
  }
}

#Preview {
  AirportRunwayView(icao: "KDSM", runways: [])
}
