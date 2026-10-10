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
  var rasterRadarAlertVisible: Bool = false
  
  var radarVisible: Bool = false
  var satelliteRadarVisible: Bool = false
  
  var wxRadarSourceID: String = "wx-radar-source"
  var satelliteRadarSourceID: String = "satellite-radar-source"
  
  var radarPopoverVisible: Bool = false
  
  var currentRadar: RainviewerSchema?
}

@Observable
class ProcedureSectionViewModel {
  var sidsVisible: Bool = false
  var starsVisible: Bool = false
  var sidRoute: [[ProcedureTable]] = []
  var starRoute: [[ProcedureTable]] = []
}

@Observable
class MapViewModel {
  var radarSectionVM = RadarSectionViewModel()
  var procedureVM = ProcedureSectionViewModel()
  
  var drawingEnabled: Bool = false
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
  
  var lgAirportsVisible: Bool = true
  var mdAirportsVisible: Bool = false
  var smAirportsVisible: Bool = false
  // Future: instead of Lg, Md, Sm visibility
  // let user control IFR vs. VFR airport visibility
  var ifrAirportsVisible: Bool = true
  var vfrAirportsVisible: Bool = true
  
  var mapSatelliteVisible: Bool = false
  
  var gatesVisible: Bool = false
  var visibleGates: [GateTable] = []
  
  var sigmetsVisible: Bool = false
  var sigmets: SigmetSchema = []
  
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
