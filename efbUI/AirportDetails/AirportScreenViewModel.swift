//
//  AirportDetailViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/6/24.
//
import Observation
import CoreLocation
import SwiftUI

@Observable
class AirportWeather {
  var prevICAO: String = ""
  var wxSource: WxSources = .faa
  var wxType: WxTabs = .metar
  var wxCategory: WxCategory = .VFR
  
  var faaMetar: [AirportMETARSchema] = []
  var faaTaf: [String] = []
  var faaAtis: [AtisAPISchema] = []
  
  var ivaoMetar: String = ""
  var ivaoAtis: String = ""
  
  var pilotedgeAtis: String = ""
  var vatsimAtis: String = ""
  
  var currentWxString: String = ""
  
  /// fetch faa/noaa metar and calculate wx category
  func fetchFaaMetar(icao: String) {
    let wx = FetchAirportWx()
    wx.fetchMetar(icao: icao) { metar in
      self.faaMetar = metar
      self.wxCategory = self.calculateWxCategory(wx: metar)
      self.currentWxString = metar.first?.rawOb ?? "n/a"
    }
  }
  
  func fetchFaaTaf(icao: String) {
    let wx = FetchAirportWx()
    wx.fetchTAF(icao: icao) { taf in
      self.faaTaf = taf
      self.currentWxString = taf.joined(separator: "\n")
    }
  }

  func fetchFaaAtis(icao: String) {
    let atisAPI = AtisAPI()
    atisAPI.fetchATIS(icao: icao) { atis in
      self.faaAtis = atis
      self.currentWxString = atis.map { $0.datis }.joined(separator: "\n")
    }
  }
  
  func fetchIvaoWx() -> String {
    return "ivao metar"
  }
  
  func fetchPilotedgeATIS(icao: String) {
    let api = PilotedgeAPI()
    api.fetchATIS(icao: icao) { atis in
      self.pilotedgeAtis = atis.joined(separator: "\n")
      self.currentWxString = self.pilotedgeAtis
    }
  }
  
  func wxCategoryColor(for category: WxCategory) -> Color {
    switch category {
    case .VFR:
      return .vfr
    case .MVFR:
      return .mvfr
    case .IFR:
      return .ifr
    case .LIFR:
      return .lifr
    }
  }
  
  func calculateWxCategory(wx: [AirportMETARSchema]) -> WxCategory {
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
  
  // TODO: no need to re-call api, if you JUST looked at the tab. How to implement that...
  // Refresh parameter?
  func fetchWx(for source: WxSources, type: WxTabs, icao: String, refresh: Bool) {
    switch (source, type) {
    case (.faa, .metar):
      if prevICAO == icao && !refresh && !self.faaMetar.isEmpty {
        self.currentWxString = self.faaMetar.first?.rawOb ?? "n/a"
      } else {
        self.fetchFaaMetar(icao: icao)
      }
    case (.faa, .taf):
      if prevICAO == icao && !refresh && !self.faaTaf.isEmpty {
        self.currentWxString = self.faaTaf.joined(separator: "\n")
      } else {
        self.fetchFaaTaf(icao: icao)
      }
    case (.faa, .atis):
      if prevICAO == icao && !refresh && !self.faaAtis.isEmpty {
        self.currentWxString = self.faaAtis.map { $0.datis }.joined(separator: "\n")
      } else {
        self.fetchFaaAtis(icao: icao)
      }
    case (.ivao, .metar):
      self.currentWxString = "ivao metar"
    case (.ivao, .taf):
      self.currentWxString = "ivao taf"
    case (.ivao, .atis):
      self.currentWxString = "ivao atis"
    case (.pilotedge, .metar):
      self.currentWxString = "n/a"
    case (.pilotedge, .taf):
      self.currentWxString = "n/a"
    case (.pilotedge, .atis):
      if prevICAO == icao && !refresh && self.pilotedgeAtis != "" {
        self.currentWxString = self.pilotedgeAtis
      } else {
        self.fetchPilotedgeATIS(icao: icao)
      }
    }
    self.prevICAO = icao
  }
}

enum WxCategory: String {
  case VFR, MVFR, IFR, LIFR
}


enum WxTabs: String, Identifiable, CaseIterable {
  case metar, taf, atis
  var id: Self { self }
}

enum WxSources: String, Identifiable, CaseIterable {
  case faa, ivao, pilotedge
  var id: Self { self }
}

@Observable
class AirportDetails: AirportWeather {
  var runways: [RunwayTable] = []
  var comms: [AirportCommunicationTable] = []
  
  /**
    fetchAirportDetails(icao: String)
    fetches runways, comms
   */
  func fetchAirportDetails(icao: String) {
    Task.detached {
      self.fetchRunways(icao: icao)
      self.fetchComms(icao: icao)
    }
  }
  
  func fetchRunways(icao: String) {
    let runways = SQLiteManager.shared.getAirportRunways(icao)
    self.runways = runways
  }
  
  func fetchComms(icao: String) {
    let comms = SQLiteManager.shared.getAirportComms(icao)
    self.comms = comms
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
  
}

enum AirportsScreenInfoTabs: String, Identifiable, CaseIterable {
  case freq = "Freq"
  case wx = "Wx"
  case rwy = "Runways"
  case localwx = "Local Wx"
  
  var id: Self { self }
}


// cityServed, sunrise/sunset, charts, local weather, selectedInfoTab
@Observable
class AirportScreenViewModel: AirportDetails {
  var selectedAirportElement: AirportSchema?
  var loadingAirportWx: Bool = false
  var selectedAirport: AirportTable?
  var osmWeatherResults: OSMWeatherSchema?
  var cityServed = ""
  var selectedInfoTab: AirportsScreenInfoTabs = .freq
  var selectedAirportCharts: DecodedArray<AirportChartAPISchema>?
  
  var selectedAirportICAO: String = "" {
    didSet {
      // Get selected airport
      selectedAirport = SQLiteManager.shared.selectAirport(selectedAirportICAO)
      if let selectedAirport {
        Task.detached {
          self.fetchAirportDetails(icao: self.selectedAirportICAO)
          self.queryAirportData(airport: selectedAirport)
        }
      }
    }
  }
  
  // MARK: AirportScreen search bar
  var airportSearchResults = [QueryAirportTextResult]()
  var searchText: String = "" {
    didSet {
      airportSearchResults = SQLiteManager.shared.queryAirports(searchText)
    }
  }
  
  /**
   Fetch Weather, fetch airport communications, fetch city/state
   */
  private func queryAirportData(airport: AirportTable) {
    fetchLocalWeather(lat: airport.airportRefLat, long: airport.airportRefLong)
    fetchCityState(lat: airport.airportRefLat, long: airport.airportRefLong)
    fetchAirportCharts(icao: airport.airportIdentifier)
  }
  
  func fetchLocalWeather(lat: Double, long: Double) {
    let weatherAPI = OSMWeatherAPI()
    weatherAPI.fetchWeather(latitude: lat, longitude: long) { [weak self] weather in
      self?.osmWeatherResults = weather
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
  
  func fetchAirportCharts(icao: String) {
    let airportCharts = FetchAirportCharts()
    airportCharts.fetchCharts(icao: icao) { charts in
      self.selectedAirportCharts = charts
    }
  }
  
}


