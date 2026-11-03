//
//  MapScreenSigmets.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/26.
//

import SwiftUI
import MapboxMaps

struct MapScreenSigmets: MapContent {
  let vm: MapViewModel
  
  var body: some MapContent {
    GeoJSONSource(id: "SigmetSource")
      .data(.featureCollection(vm.sigmets))
    
    FillLayer(id: "SigmetFill", source: "SigmetSource")
      .fillColor(.systemBlue) // properties > hazard (CONV, ICING, etc.)
      .fillOpacity(0.4)
      .slot(.middle)
    
  }
  
  func getSigmetFillColor(sigmet: String) -> StyleColor {
    switch sigmet {
    case "ICE":
      return .init(.blue)
    case "TURB":
      return .init(.red)
    case "CONVECTIVE":
      return .init(.orange)
    default:
      return .init(.gray)
    }
  }
}
