//
//  AirportDetailViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/6/24.
//

import CoreLocation

@Observable
class AirportDetailViewModel {
  static let shared = AirportDetailViewModel()
  var selectedAirportElement: Airport?
  var airportWx: AirportMetarInfo? = nil
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
    if let freq = comms?.first(where: { $0.communicationType == type} ) {
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
    airportWx.fetchMetarTaf(icao: icao) { weather in
      self.airportWx = weather
      self.loadingAirportWx = false
    }
  }
  
  func calculateWxCategory(wx: AirportMetarInfo) -> WxCategory {
    /*
     Cloud Ceiling Def: Height of the BASE of the LOWEST clouds that cover MORE than HALF of the sky (BKN, OVC)
     FEW: 1/8 to 2/8 | SCT: 3/8 to 4/8 | BKN: 5/8 to 7/8 | OVC: 8/8
     
     VFR (Green), MVFR (Blue), IFR (Red), LIFR (Magenta)
     
     VFR:  Ceiling >3,000ft      AND    Vis > 5sm
     MVFR: Ceiling 1,000-3,000ft AND/OR Vis 3-5sm
     IFR:  Ceiling 500-1000ft    AND/OR Vis 1-3sm
     LIFR: Ceiling <500ft        AND/OR Vis <1sm
     
     ex/ KDSM 311254Z 32016G24KT 4SM -SN OVC006 M02/M04 A3007 RMK AO2 SNE29B48 SLP191 P0000 T10171044 clouds=[cover: "OVC", base: 1300]
     - MVFR
     
     */
    guard let wx = wx.first else { return .NA }
    
    var lowestBase: Int = 5000
    var visib: Double = 10
    var currWx: WxCategory = .VFR
    
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
    
    switch visib {
    case ...3:
      currWx = .LIFR
    case 3...5:
      currWx = .IFR
    case 5...10:
      currWx = .MVFR
    default:
      currWx = .VFR
    }
    
    switch lowestBase {
    case ...500:
      currWx = .LIFR
    case 500...1000:
      currWx = .IFR
    case 1000...3000:
      currWx = .MVFR
    default:
      currWx = .VFR
    }
    
    return currWx
    
  }
  
  func fetchAirportCharts(icao: String) {
    let airportCharts = FetchAirportCharts()
    airportCharts.fetchCharts(icao: icao) { charts in
      self.selectedAirportCharts = charts
    }
  }
  
}

enum WxCategory: String {
  case VFR, MVFR, IFR, LIFR, NA
}
