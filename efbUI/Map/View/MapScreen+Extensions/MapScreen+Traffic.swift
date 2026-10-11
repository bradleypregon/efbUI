//
//  MapScreen+Traffic.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/10/26.
//

import SwiftUI
import MapboxMaps

// MARK: New Traffic
extension MapScreen {
  @MapContentBuilder
  var trafficContent: some MapContent {
    GeoJSONSource(id: "TrafficSource")
      .data(.featureCollection(vm.trafficFeatures))
    
    SymbolLayer(id: "TrafficLayer", source: "TrafficSource")
      .iconImage("traffic")
      .iconRotate(Exp(.get) { "hdg" })
      .iconRotationAlignment(.map)
      .iconAllowOverlap(true)
      .textField(Exp(.get) { "reg" })
      .textOffset(x: 0, y: 2)
      .textSize(7)
      .textColor(.white)
      .textFont(["Roboto Bold Condensed"])
      .textOptional(true)
      .slot(.top)
    
    // Traffic Reg and Alt labels
    SymbolLayer(id: "TrafficRegLayer", source: "TrafficSource")
      .textField(Exp(.get) { "reg" })
      .textOffset(x: 0, y: 2)
      .textSize(7)
      .textColor(.white)
      .textFont(["Roboto Bold Condensed"])
      .slot(.top)
    SymbolLayer(id: "TrafficAltLayer", source: "TrafficSource")
      .textField(Exp(.get) { "alt" })
      .textSize(7)
      .textOffset(x: 0, y: -2)
      .textColor(.white)
      .textFont(["Roboto Bold Condensed"])
      .slot(.top)
    
    if let ownship = vm.ownship {
      LocationIndicatorLayer(id: "OwnshipLayer")
        .topImage("ownship")
        .location(ownship.coordinate) // Altitude not working?
        .bearing(ownship.heading)
        .slot(.top)
    }
  }
}
