//
//  MapView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//

import SwiftUI
import MapboxMaps

struct MapView: View {
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  
  var body: some View {
    MapReader { proxy in
      Map(viewport: $viewport) { }
        .mapStyle(
          MapStyle(uri: StyleURI(rawValue: Bundle.main.object(forInfoDictionaryKey: "MapStyleURI") as? String ?? "") ?? .dark)
        )
        .ornamentOptions(ornamentOptions)
    }
    .ignoresSafeArea()
  }
}

#Preview {
  MapView()
}
