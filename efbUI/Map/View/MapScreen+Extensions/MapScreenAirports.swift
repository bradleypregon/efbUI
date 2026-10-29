//
//  MapScreen+Airports.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/20/26.
//

import SwiftUI
import MapboxMaps

/* todo
 - allow user to change zoom/visible thresholds
 - Toggle to turn off IFR-only or VFR-only airports
 */

struct MapScreenAirports: MapContent {
  let vm: MapViewModel
  @Binding var splitViewVisibility: Bool
  
  var body: some MapContent {
    airportLayer(id: Id.smAirports, size: "Small", icon: "airportVfr", iconSize: 1.05, minZoom: 8)
    airportLayer(id: Id.mdAirports, size: "Medium", icon: "airportIfr", iconSize: 1.1, minZoom: 5)
    airportLayer(id: Id.lgAirports, size: "Large", icon: "airportIfr", iconSize: 1.15, minZoom: 0)
    
    TapInteraction(.layer(Id.lgAirports)) { feature, _ in
      tapInteraction(feature: feature)
      return true
    }
    
    TapInteraction(.layer(Id.mdAirports)) { feature, _ in
      tapInteraction(feature: feature)
      return true
    }
    
    TapInteraction(.layer(Id.smAirports)) { feature, _ in
      tapInteraction(feature: feature)
      return true
    }
  }
  
  func airportLayer(id: String, size: String, icon: String, iconSize: Double, minZoom: Double) -> SymbolLayer {
    return SymbolLayer(id: id, source: Id.airportSource)
      .filter(Exp(.eq) { Exp(.get) { "size" }; size })
      .minZoom(minZoom)
      .iconImage(icon) // airportVfr/Ifr
      .iconSize(iconSize) // 1.05, 1.1, 1.15
      .iconColor(.lifr)
      .textField(Exp(.get) { "icao" })
      .textOffset(x: 0.0, y: -1.85)
      .textColor(.white)
      .textSize(13)
      .textHaloWidth(1.35)
      .textHaloColor(.black)
  }
  
  func tapInteraction(feature: FeaturesetFeature) {
    guard let icao = feature.properties["icao"]??.rawValue as? String else {
      print("Something went wrong interacting with Airport Annotation")
      return
    }
    vm.selection = .airport(icao: icao)
    splitViewVisibility = true
  }
  
}
