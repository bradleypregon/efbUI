//
//  AirportScreen.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/21.
//

import SwiftUI
import CoreLocation

struct AirportSunriseSunsetView: View {
  var weather: OSMWeatherSchema?
  
  var body: some View {
    HStack(spacing: 1) {
      Image(systemName: "sunrise.fill")
      Text("\(convertTime(weather?.current.sunrise ?? .zero))")
      Spacer().frame(width: 5)
      Image(systemName: "sunset.fill")
      Text("\(convertTime(weather?.current.sunset ?? .zero))")
    }
  }
  
  func convertTime(_ timestamp: Int) -> String {
    if timestamp == 0 { return "" }
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    df.timeZone = .autoupdatingCurrent
    return df.string(from: date)
  }
}

struct AirportScreen: View {
  @Binding var selectedTab: Int
  @Environment(AirportDetailViewModel.self) private var airportDetailViewModel
  @State private var textFieldFocused: Bool = false
  
  var body: some View {
    @Bindable var airportDetailViewModel = airportDetailViewModel
    
    NavigationStack {
      ZStack {
        VStack(spacing: 30) {
          if airportDetailViewModel.selectedAirport != nil {
            HStack {
              Grid(alignment: .leading) {
                GridRow {
                  Text(airportDetailViewModel.cityServed)
                }
                GridRow {
                  Text(airportDetailViewModel.formatAirportCoordinates(lat: airportDetailViewModel.selectedAirport?.airportRefLat ?? .zero, long: airportDetailViewModel.selectedAirport?.airportRefLong ?? .zero))
                }
                GridRow {
                  AirportSunriseSunsetView(weather: airportDetailViewModel.osmWeatherResults)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 20)
              HStack {
                Grid(alignment: .leading) {
                  GridRow {
                    Text("Flight category")
                      .font(.subheadline)
                    if airportDetailViewModel.airportWxMetar != nil {
                      Text(airportDetailViewModel.wxCategory.rawValue)
                        .fontWeight(.semibold)
                        .foregroundStyle(airportDetailViewModel.wxCategory == .MVFR ? Color.mvfr : airportDetailViewModel.wxCategory == .IFR ? Color.ifr : airportDetailViewModel.wxCategory == .LIFR ? Color.lifr : Color.vfr)
                    } else {
                      Text("N/A")
                        .fontWeight(.semibold)
                    }
                  }
                  GridRow {
                    Text("Elevation")
                      .font(.subheadline)
                    Text("\(airportDetailViewModel.selectedAirport?.elevation ?? .zero)'")
                      .fontWeight(.semibold)
                  }
                  GridRow(alignment: .center) {
                    Button {
                      selectedTab = 2
                    } label: {
                      Text("View Charts")
                    }
                    .buttonStyle(.bordered)
                  }
                }
                Grid(alignment: .leading) {
                  GridRow {
                    Text("ATIS")
                      .font(.subheadline)
                    Text(airportDetailViewModel.getCommunicationType(comms: airportDetailViewModel.selectedAirportComms, type: "ATI"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Clearance")
                      .font(.subheadline)
                    Text(airportDetailViewModel.getCommunicationType(comms: airportDetailViewModel.selectedAirportComms, type: "CLD"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Ground")
                      .font(.subheadline)
                    Text(airportDetailViewModel.getCommunicationType(comms: airportDetailViewModel.selectedAirportComms, type: "GND"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Tower")
                      .font(.subheadline)
                    Text(airportDetailViewModel.getCommunicationType(comms: airportDetailViewModel.selectedAirportComms, type: "TWR"))
                      .fontWeight(.semibold)
                  }
                }
              }
              .frame(maxWidth: .infinity, alignment: .center)
              
            }
          } else {
            ContentUnavailableView("Airport Details Unvailable", systemImage: "airplane.circle", description: Text("Select an airport to view details."))
              .frame(maxHeight: 200)
          }
          
          Picker(selection: $airportDetailViewModel.selectedInfoTab, label: Text("Picker")) {
            ForEach(AirportsScreenInfoTabs.allCases, id: \.id) { tab in
              Text(tab.rawValue)
                .tag(tab)
            }
          }
          .pickerStyle(.segmented)
          AirportScreenInfoTabBuilder(selectedTab: airportDetailViewModel.selectedInfoTab, airportVM: airportDetailViewModel)
          Spacer()
        }
        .navigationTitle("\(airportDetailViewModel.selectedAirport?.airportName ?? "Airport Details")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          TextField("Search Airports...", text: $airportDetailViewModel.searchText)
            .textFieldStyle(.roundedBorder)
          // TODO: Find better way to handle tap gesture to reveal popover
            .onTapGesture {
              textFieldFocused.toggle()
            }
            .frame(width: 300)
            .popover(isPresented: $textFieldFocused, content: {
              if airportDetailViewModel.searchText.count > 1 {
                List {
                  ForEach(airportDetailViewModel.airportSearchResults) { result in
                    Button {
                      airportDetailViewModel.selectedAirport = SQLiteManager.shared.selectAirport(result.airportIdentifier)
                      airportDetailViewModel.selectedAirportICAO = result.airportIdentifier
                    } label: {
                      Text("\(result.airportIdentifier) - \(result.airportName)")
                    }
                    .listRowSeparator(.visible)
                  }
                }
                .listStyle(.plain)
                .frame(idealWidth: 300, idealHeight: 300, maxHeight: 500)
              } else {
                Color.clear
                  .frame(idealWidth: 300, idealHeight: 300)
              }
            })
        }
      }
      
    }
    .onAppear {
      // fetch metar, weather, local weather, etc
    }
  }
  
}

struct AirportScreenInfoTabBuilder: View {
  let selectedTab: AirportsScreenInfoTabs
  let airportVM: AirportDetailViewModel
  
  @ViewBuilder
  var body: some View {
    switch selectedTab {
    case .freq:
      if let comms = airportVM.selectedAirportComms {
        AirportScreenFreqTab(comms: comms)
      } else {
        ContentUnavailableView("Frequencies INOP", systemImage: "", description: Text("Select an airport to view frequencies."))
      }
    case .wx:
      AirportScreenWxTab(metar: airportVM.airportWxMetar, taf: airportVM.airportWxTAF, airportVM: airportVM)
    case .rwy:
      if airportVM.selectedAirportRunways != nil {
        AirportScreenRwyTab(runways: airportVM.selectedAirportRunways, wx: airportVM.airportWxMetar)
      } else {
        ContentUnavailableView("Runways INOP", systemImage: "", description: Text("Select an airport to view runways."))
      }
    case .localwx:
      if airportVM.osmWeatherResults != nil {
        AirportScreenLocalWxTab(localwx: airportVM.osmWeatherResults)
      } else {
        ContentUnavailableView("Local Wx INOP", systemImage: "", description: Text("Select an airport to view local weather."))
      }
    }
  }
}

struct AirportScreenFreqTab: View {
  let comms: [AirportCommunicationTable]
  
  var body: some View {
    let groupedItems = Dictionary(grouping: comms, by: { $0.communicationType })
    
    ScrollView(.vertical) {
      Grid(alignment: .leading) {
        ForEach(groupedItems.keys.sorted(), id:\.self) { commType in
          Section(commType) {
            ForEach(groupedItems[commType]?.sorted(by: { $0.communicationFrequency < $1.communicationFrequency }) ?? [], id: \.self) { comm in
              GridRow {
                Text(comm.communicationType)
                if comm.frequencyUnits != "V" {
                  Text("\(comm.frequencyUnits)-\(comm.communicationFrequency.string)")
                } else {
                  Text("\(comm.communicationFrequency.string)")
                }
                Text(comm.callsign)
              }
              .font(.system(size: 16, design: .default))
            }
          }
          .font(.title)
          .fontWeight(.semibold)
        }
      }
      .frame(idealWidth: 250)
    }
  }
}

struct AirportScreenWxTab: View {
  let metar: AirportMETARSchema?
  let taf: [String]?
  let airportVM: AirportDetailViewModel
  
  var body: some View {
    ScrollView {
      Text("METAR")
        .font(.title)
      if let metar = metar?.first, let ob = metar.rawOb {
        Text(ob)
      } else {
        ContentUnavailableView("METAR INOP", systemImage: "", description: Text("METAR may be unavailable or an internal fault happened."))
      }
      
      Text("TAF")
        .font(.title2)
      if let taf = taf {
        ForEach(taf, id: \.self) { taf in
          Text(taf)
        }
        .frame(alignment: .leading)
      } else {
        ContentUnavailableView("TAF INOP", systemImage: "", description: Text("TAF may be unavailable or an internal fault happened."))
      }
      
      HStack {
        Text("ATIS")
          .font(.title2)
        Button {
          do {
            try airportVM.fetchATIS(icao: airportVM.selectedAirportICAO)
          } catch {
            print("atis failed for: \(airportVM.selectedAirportICAO)")
          }
          
        } label: {
          Text("Refresh")
        }
      }
      if let atis = airportVM.atis {
        ForEach(atis, id:\.self) { atis in
          Text(atis.datis)
        }
      } else {
        ContentUnavailableView("ATIS INOP", systemImage: "", description: Text("ATIS unavailable"))
      }
    }
    .refreshable {
      guard airportVM.selectedAirportICAO != "" else { return }
      airportVM.fetchAirportWx(icao: airportVM.selectedAirportICAO)
    }
  }
}

// TODO: Organize Runways, build runway model things?
// TODO: Runway models with wind direction showing?
// TODO: If RVR is less than length of runway, draw line displaying RVR of runway?
struct AirportScreenRwyTab: View {
  let runways: [RunwayTable]?
  let wx: AirportMETARSchema?
  
  @State var optimalRunways: [RunwayTable] = []
  @State var longestRunways: [RunwayTable] = []
  
  var body: some View {
    if let runways {
      ScrollView(.vertical) {
        WrappingHStack(models: runways) { runway in
          AirportRunwayView(runway: runway, weather: wx, optimal: isOptimal(runway), longest: isLongest(runway))
        }
      }
      .onAppear {
        getOptimalRunways()
        getLongestRunways()
      }
    }
  }
  
  func getOptimalRunways() {
    self.optimalRunways = []
    guard let runways = runways else { return }
    guard let dir = wx?.first?.wdir else { return }
    if dir == 0 { return }
    
    let runwayDiff = runways.map { ($0, abs($0.runwayMagneticBearing - Double(dir))) }
    
    let sortedRunways = runwayDiff.sorted { $0.1 < $1.1 }
    
    self.optimalRunways = sortedRunways.filter { $0.1 == sortedRunways.first?.1 }.map { $0.0 }
  }
  
  func getLongestRunways() {
    self.longestRunways = []
    guard let runways = runways else { return }
    var longestLength = 0
    
    for runway in runways {
      if runway.runwayLength > longestLength {
        longestLength = runway.runwayLength
        self.longestRunways = [runway]
      } else if runway.runwayLength == longestLength {
        self.longestRunways.append(runway)
      }
    }
  }
  
  func isOptimal(_ runway: RunwayTable) -> Bool {
    return optimalRunways.contains(runway)
  }
  
  func isLongest(_ runway: RunwayTable) -> Bool {
    return longestRunways.contains(runway)

  }
}

// TODO: Lots we can do here to stylize
struct AirportScreenLocalWxTab: View {
  let localwx: OSMWeatherSchema?
  
  var body: some View {
    if let localwx {
      Text("\(localwx.current.temp.string)")
      Text("main: \(localwx.current.weather.first?.main ?? "")")
      Text("desc: \(localwx.current.weather.first?.description ?? "")")
      
    }
  }
}


//#Preview {
//  AirportScreen(selectedTab: .constant(0))
//}

