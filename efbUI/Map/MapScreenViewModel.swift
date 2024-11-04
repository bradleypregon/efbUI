//
//  MapScreenViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/4/24.
//


import SwiftUI
import Observation

@Observable
class MapScreenViewModel {
  var airportJSONModel = AirportJSONModel()
  var largeAirports: [AirportSchema] = []
  var mediumAirports: [AirportSchema] = []
  var smallAirports: [AirportSchema] = []
  
  var displayRadar: Bool = false
  var displaySatelliteRadar: Bool = false
  var wxRadarSourceID: String = ""
  var satelliteRadarSourceID: String = ""
  var displayRoute: Bool = false
  var displaySigmet: Bool = false
  var displayLg: Bool = true
  var displayMd: Bool = false
  var displaySm: Bool = false
  var displaySID: Bool = false
  var displaySTAR: Bool = false
  var gatesVisible: Bool = false
  
  var satelliteVisible: Bool = false
  
  var visibleGates: [GateTable] = []
  
  var currentRadar: RainviewerSchema? = nil
  
  var sigmets: SigmetSchema = []
  
  init() {
    largeAirports = airportJSONModel.airports.filter { $0.size == .large }
    mediumAirports = airportJSONModel.airports.filter { $0.size == .medium }
    smallAirports = airportJSONModel.airports.filter { $0.size == .small }
  }
  
  func fetchVisibleGates() {
    visibleGates = SQLiteManager.shared.getAirportGates("KLAX")
  }
}
