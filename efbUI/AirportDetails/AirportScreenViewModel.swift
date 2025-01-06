//
//  AirportDetailViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/6/24.
//
import Observation
import CoreLocation
import SwiftUI

enum WxCategory: String {
  case VFR, MVFR, IFR, LIFR, NONE
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
class AirportDetails {
  var runways: [RunwayTable] = []
  var comms: [AirportCommunicationTable] = []
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
  
  /**
    fetchAirportDetails(icao: String)
    fetches runways, comms
   */
  func fetchAirportDetails(icao: String) async {
    await self.fetchRunways(icao: icao)
    await self.fetchComms(icao: icao)
  }
  
  func fetchRunways(icao: String) async {
    let runways = await SQLiteManager.shared.getAirportRunways(icao)
    self.runways = runways
  }
  
  func fetchComms(icao: String) async {
    let comms = await SQLiteManager.shared.getAirportComms(icao)
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
  
  func getATIS(comms: [AirportCommunicationTable]?) -> [AirportCommunicationTable] {
    let types = ["ATI", "AWO", "ASO", "AWI", "AWS"]
    guard comms != nil else { return [] }
    guard let filter = comms?.filter({ $0.frequencyUnits == "V" && types.contains($0.communicationType)}) else { return [] }
    print(filter)
    let sorted = sortWx(wx: filter)
    return sorted
  }
  
  func sortWx(wx: [AirportCommunicationTable]) -> [AirportCommunicationTable] {
    let ranking: [String: Int] = [
      "ATI": 1,
      "AWO": 2,
      "ASO": 3,
      "AWI": 4,
      "AWS": 5
    ]
    
    return wx.sorted { (a, b) -> Bool in
      let rankA = ranking[a.communicationType] ?? Int.max
      let rankB = ranking[b.communicationType] ?? Int.max
      return rankA < rankB
    }
  }
  
  /// fetch faa/noaa metar and calculate wx category
  func fetchFaaMetar(icao: String) async {
    do {
      let metars = try await AirportWxAPI().fetchMetar(icao: icao)
      self.faaMetar = metars
      self.wxCategory = self.calculateWxCategory(wx: metars)
      self.currentWxString = metars.first?.rawOb ?? "metar n/a"
    } catch AirportWxError.invalidURL {
      // TODO: Handle AirportWxError types
      print(AirportWxError.invalidURL.localizedDescription)
    } catch AirportWxError.invalidResponse {
      print(AirportWxError.invalidResponse.localizedDescription)
    } catch (AirportWxError.invalidDecode) {
      print(AirportWxError.invalidDecode.localizedDescription)
    } catch {
      print("An unexpected issue ocurred fetching AirportWxAPI METARs for Airport.")
    }
  }
  
  func fetchFaaTaf(icao: String) async {
    do {
      let tafs = try await AirportWxAPI().fetchTAF(icao: icao)
      self.faaTaf = tafs
    } catch AirportWxError.invalidURL {
      // TODO: Handle AirportWxError types
      print(AirportWxError.invalidURL.localizedDescription)
    } catch AirportWxError.invalidResponse {
      print(AirportWxError.invalidResponse.localizedDescription)
    } catch (AirportWxError.invalidDecode) {
      print(AirportWxError.invalidDecode.localizedDescription)
    } catch {
      print("An unexpected issue ocurred fetching AirportWxAPI TAFs for Airport.")
    }
  }

  func fetchFaaAtis(icao: String) async {
    let atisAPI = FaaAtisAPI()
    do {
      self.faaAtis = try await atisAPI.fetchATIS(icao: icao)
      self.currentWxString = self.faaAtis.map { $0.datis }.joined(separator: "\n")
    } catch FaaAtisError.badURL {
      print("Bad URL for FaaAtisAPI")
    } catch FaaAtisError.badResponse {
      print("Bad response for FaaAtisAPI")
    } catch FaaAtisError.badData {
      print("Bad data for FaaAtisAPI")
    } catch {
      print("Unexpected error fetching from FaaAtisAPI")
    }
  }
  
  func fetchIvaoWx() -> String {
    return "ivao metar"
  }
  
  func fetchPilotedgeATIS(icao: String) async {
    do {
      self.pilotedgeAtis = try await PilotedgeAPI().fetchATIS(icao: icao).joined(separator: "\n")
      self.currentWxString = self.pilotedgeAtis
    } catch let error {
      print("Error with pilotedge atis: \(error)")
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
    case .NONE:
      return .primary
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
    guard let wx = wx.first else { return .NONE }
    
    var lowestBase: Int = 4000
    var visib: Double = 10
    
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
  func fetchWx(for source: WxSources, type: WxTabs, icao: String, refresh: Bool) async {
    switch (source, type) {
    case (.faa, .metar):
      if prevICAO == icao && !refresh && !self.faaMetar.isEmpty {
        self.currentWxString = self.faaMetar.first?.rawOb ?? "n/a"
      } else {
        await self.fetchFaaMetar(icao: icao)
      }
    case (.faa, .taf):
      if prevICAO == icao && !refresh && !self.faaTaf.isEmpty {
        self.currentWxString = self.faaTaf.joined(separator: "\n")
      } else {
        await self.fetchFaaTaf(icao: icao)
      }
    case (.faa, .atis):
      if prevICAO == icao && !refresh && !self.faaAtis.isEmpty {
        self.currentWxString = self.faaAtis.map { $0.datis }.joined(separator: "\n")
      } else {
        await fetchFaaAtis(icao: icao)
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
        await self.fetchPilotedgeATIS(icao: icao)
      }
    }
    self.prevICAO = icao
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
  var requestMap: Bool = false
  var selectedAirport: AirportTable?
  var localWeatherResults: OpenMeteoSchema?
  var cityServed = ""
  var selectedInfoTab: AirportsScreenInfoTabs = .freq
  var selectedAirportCharts: DecodedArray<AirportChartAPISchema>?
  
  var selectedAirportICAO: String = "" {
    didSet {
      // Get selected airport
      selectedAirport = SQLiteManager.shared.selectAirport(selectedAirportICAO)
      if let selectedAirport {
        Task {
          await self.fetchAirportDetails(icao: self.selectedAirportICAO)
          await self.queryAirportData(airport: selectedAirport)
          await self.fetchFaaMetar(icao: self.selectedAirportICAO)
        }
      }
    }
  }
  
  /**
   Fetch Weather, fetch airport communications, fetch city/state
   */
  private func queryAirportData(airport: AirportTable) async {
    await fetchLocalWeather(lat: airport.airportRefLat, long: airport.airportRefLong)
    fetchCityState(lat: airport.airportRefLat, long: airport.airportRefLong)
    await fetchAirportCharts(icao: airport.airportIdentifier)
  }
  
  func fetchLocalWeather(lat: Double, long: Double) async {
    do {
      self.localWeatherResults = try await OpenMeteoAPI().fetchWeather(latitude: lat, longitude: long)
    } catch let error {
      print(error)
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
    return "\(formattedLat) / \(formattedLong)"
  }
  
  func fetchAirportCharts(icao: String) async {
    do {
      self.selectedAirportCharts = try await AirportChartAPI().fetchCharts(icao: icao)
    } catch {
      print("err")
    }
  }
  
}


