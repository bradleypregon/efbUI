//
//  MapAirports.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/21/25.
//

import SwiftUI
import MapboxMaps
import Foundation

class AirportFeatures {
  let features: [Feature]
  init(features: [Feature]) { self.features = features }
}

struct LazyGeoJSON: MapContent {
  let id: String
  let features: AirportFeatures
  
  var body: some MapContent {
    GeoJSONSource(id: id)
      .data(.featureCollection(FeatureCollection(features: features.features)))
      
  }
}
