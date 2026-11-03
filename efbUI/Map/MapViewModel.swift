//
//  MapScreenViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/4/24.
//


import SwiftUI
import Observation
import MapboxMaps
import MapKit

@Observable
class RadarSectionViewModel {
  var compositeRadarVisible: Bool = false
  var satelliteRadarVisible: Bool = false
  
  var compositeRadarSourceID: String = "composite-radar-source"
  var satelliteRadarSourceID: String = "satellite-radar-source"
  
  var currentRadar: LibrewxrSchema?
}

@Observable
class ProcedureSectionViewModel {
  var sidsVisible: Bool = false
  var starsVisible: Bool = false
  var sidRoute: [[ProcedureTable]] = []
  var starRoute: [[ProcedureTable]] = []
}

@Observable
final class MapViewModel: Sendable {
  var radarVM = RadarSectionViewModel()
  var procedureVM = ProcedureSectionViewModel()
  
  var waypointPopoverVisible: Bool = false
  var routeVisible: Bool = false
  
  var sigmetMenuPopoverVisible: Bool = false
  var sigmetSliderRange: ClosedRange<Float> = 1000...41000
  
  var featureCollection: FeatureCollection = .init(features: [])
  
  var traffic: [Int: SimConnectShip] = [:]
  var trafficFeatures: FeatureCollection {
    FeatureCollection(features: traffic.values.map { ship in
      var feature = Feature(geometry: .point(Point(ship.coordinate)))
      feature.identifier = .string(String(ship.fs2ffid))
      feature.properties = [
        "reg": .string(ship.registration ?? UUID().uuidString),
        "alt": .string(String(Int(ship.altitude))),
        "hdg": .number(ship.heading)
      ]
      return feature
    })
  }
  
  var ownship: SimConnectShip? = nil
  
  var displayRoute: Bool = false
  
  // Future: instead of Lg, Md, Sm visibility
  // let user control IFR vs. VFR airport visibility
  var ifrAirportsVisible: Bool = true
  var vfrAirportsVisible: Bool = true
  
  var mapSatelliteVisible: Bool = false
  
  var gatesVisible: Bool = false
  var visibleGates: [GateTable] = []
  
  var sigmetsVisible: Bool = false
  var sigmets: FeatureCollection = FeatureCollection(features: [])
  
  var sidsVisible: Bool = false
  var starsVisible: Bool = false
  var sidRoute: [[ProcedureTable]] = []
  var starRoute: [[ProcedureTable]] = []
  
  var enrouteCommsVisible: Bool = false
  var enrouteComms: [EnrouteCommTable] = []
  
  enum MapSelection: Hashable {
    case airport(icao: String)
    // case runway, case airway, navaid ...
  }
  
  enum MapSelectionDetail {
    case airport(AirportTable)
    // case airway(AirwayTable), case runway(RunwayTable) ...
  }
  
  var selection: MapSelection?
  var selectionDetail: MapSelectionDetail?
  
  func fetchVisibleGates() {
//    visibleGates = SQLiteManager.shared.getAirportGates("KLAX")
  }
}
