//
//  AirportDetailViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/6/24.
//
import Observation
import CoreLocation
import SwiftUI

enum AirportsScreenInfoTabs: String, Identifiable, CaseIterable {
  case freq = "Freq"
  case wx = "Wx"
  case rwy = "Runways"
//  case chart = "Charts"
  case localwx = "Local Wx"
  
  var id: Self { self }
}

@Observable
class AirportDetailViewModel {
//  static let shared = AirportDetailViewModel()
  var selectedAirportElement: AirportSchema?
  var airportWxMetar: AirportMETARSchema? = nil
  var airportWxTAF: AirportTAFSchema? = nil
  var loadingAirportWx: Bool = false
  
  var selectedAirportICAO: String = "" {
    didSet {
      // get selected airport
      selectedAirport = SQLiteManager.shared.selectAirport(selectedAirportICAO)
      if let selectedAirport {
        DispatchQueue.main.async {
          self.queryAirportData(airport: selectedAirport)
        }
      }
    }
  }
  
  var airportSearchResults = [QueryAirportTextResult]()
  var searchText: String = "" {
    didSet {
      airportSearchResults = SQLiteManager.shared.queryAirports(searchText)
    }
  }
  
  var selectedAirport: AirportTable?
  var selectedAirportComms: [AirportCommunicationTable]?
  var selectedAirportRunways: [RunwayTable]?
  var osmWeatherResults: OSMWeatherSchema?
  var cityServed = ""
  var selectedInfoTab: AirportsScreenInfoTabs = .freq
  var selectedAirportCharts: DecodedArray<AirportChartAPISchema>?
  var wxCategory: WxCategory = .VFR
  
  private func queryAirportData(airport: AirportTable) {
    /**
     Fetch Weather, fetch airport communications, fetch city/state
     */
    fetchWeather(lat: airport.airportRefLat, long: airport.airportRefLong)
    fetchAirportWx(icao: airport.airportIdentifier)
    selectedAirportComms = SQLiteManager.shared.getAirportComms(airport.airportIdentifier)
    fetchCityState(lat: airport.airportRefLat, long: airport.airportRefLong)
    fetchAirportCharts(icao: airport.airportIdentifier)
    selectedAirportRunways = SQLiteManager.shared.getAirportRunways(airport.airportIdentifier)
    
    if let wx = self.airportWxMetar {
      wxCategory = calculateWxCategory(wx: wx)
    }
  }
  
  func fetchWeather(lat: Double, long: Double) {
    let weatherAPI = OSMWeatherAPI()
    weatherAPI.fetchWeather(latitude: lat, longitude: long) { [weak self] weather in
      self?.osmWeatherResults = weather
    }
  }
  
  func getCommunicationType(comms: [AirportCommunicationTable]?, type: String) -> String {
    if comms == nil { return "" }
    var frequency = ""
    if let freq = comms?.first(where: { $0.communicationType == type && $0.frequencyUnits == "V"} ) {
      frequency = freq.communicationFrequency.string
      return frequency
    } else {
      return "n/a"
    }
  }
  
  func fetchCityState(lat: Double, long: Double) {
    let location = CLLocation(latitude: lat, longitude: long)
    location.fetchCityState { city, state, error in
      guard let city = city, let state = state, error == nil else { return }
      let cityState = "\(city), \(state)"
      self.cityServed = cityState
    }
  }
  
  func formatAirportCoordinates(lat: Double, long: Double) -> String {
    let formattedLat = String(format: "%.2f", lat)
    let formattedLong = String(format: "%.2f", long)
    return "\(formattedLat)/\(formattedLong)"
  }
  
  func fetchAirportWx(icao: String) {
    self.loadingAirportWx = false
    self.loadingAirportWx = true
    let airportWx = FetchAirportWx()
    airportWx.fetchMetar(icao: icao) { metar in
      self.airportWxMetar = metar
      self.loadingAirportWx = false
    }
    airportWx.fetchTAF(icao: icao) { taf in
      self.airportWxTAF = taf
      self.loadingAirportWx = false
    }
  }
  
  func calculateWxCategory(wx: AirportMETARSchema) -> WxCategory {
    /*
     Cloud Ceiling Def: Height of the BASE of the LOWEST clouds that cover MORE than HALF of the sky (BKN, OVC)
     FEW: 1/8 to 2/8 | SCT: 3/8 to 4/8 | BKN: 5/8 to 7/8 | OVC: 8/8
     
     VFR (Green), MVFR (Blue), IFR (Red), LIFR (Magenta)
     
     VFR:  Ceiling >3,000ft      AND    Vis > 5sm
     MVFR: Ceiling 1,000-3,000ft AND/OR Vis 3-5sm
     IFR:  Ceiling 500-1000ft    AND/OR Vis 1-3sm
     LIFR: Ceiling <500ft        AND/OR Vis <1sm
     */
    guard let wx = wx.first else { return .VFR }
    
    var lowestBase: Int = 4000
    var visib: Double = 10
    //    var currWx: WxCategory = .VFR
    
    switch wx.visib {
    case .int(let int):
      visib = Double(int)
    case .double(let double):
      visib = double
    case .string(_):
      visib = 10
    }
    
    // Check clouds
    if let clouds = wx.clouds {
      for cloud in clouds {
        if let base = cloud.base, let cover = cloud.cover {
          if cover == "BKN" || cover == "OVC" {
            // find lowest base of cloud
            if base < lowestBase {
              lowestBase = base
            }
          }
        }
      }
    }
    
    if lowestBase >= 3000 && visib >= 5 {
      return .VFR
    } else if lowestBase >= 1000 && visib >= 3 {
      return .MVFR
    } else if lowestBase >= 500 && visib >= 1 {
      return .IFR
    } else {
      return .LIFR
    }
    
  }
  
  func fetchAirportCharts(icao: String) {
    let airportCharts = FetchAirportCharts()
    airportCharts.fetchCharts(icao: icao) { charts in
      self.selectedAirportCharts = charts
    }
  }
  
}

enum WxCategory: String {
  case VFR, MVFR, IFR, LIFR
}
