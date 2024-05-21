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
    if let weather = weather {
      HStack(spacing: 1) {
        Image(systemName: "sunrise.fill")
        Text("\(convertTime(weather.current.sunrise))")
        Spacer()
          .frame(width: 5)
        Image(systemName: "sunset.fill")
        Text("\(convertTime(weather.current.sunset))")
      }
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
  @Environment(AirportScreenViewModel.self) private var viewModel
  @State private var textFieldFocused: Bool = false
  
  var body: some View {
    @Bindable var viewModel = viewModel
    
    NavigationStack {
      ZStack {
        VStack(spacing: 30) {
          if viewModel.selectedAirport != nil {
            HStack {
              Grid(alignment: .leading) {
                GridRow {
                  Text(viewModel.cityServed)
                }
                GridRow {
                  Text(viewModel.formatAirportCoordinates(lat: viewModel.selectedAirport?.airportRefLat ?? .zero, long: viewModel.selectedAirport?.airportRefLong ?? .zero))
                }
                GridRow {
                  AirportSunriseSunsetView(weather: viewModel.osmWeatherResults)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 20)
              HStack {
                Grid(alignment: .leading) {
                  GridRow {
                    Text("Flight category")
                      .font(.subheadline)
                    if !viewModel.faaMetar.isEmpty {
                      Text(viewModel.wxCategory.rawValue)
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.wxCategoryColor(for: viewModel.wxCategory))
                    } else {
                      Text("N/A")
                        .fontWeight(.semibold)
                    }
                  }
                  GridRow {
                    Text("Elevation")
                      .font(.subheadline)
                    Text("\(viewModel.selectedAirport?.elevation ?? .zero)'")
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
                    Text(viewModel.getCommunicationType(comms: viewModel.comms, type: "ATI"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Clearance")
                      .font(.subheadline)
                    Text(viewModel.getCommunicationType(comms: viewModel.comms, type: "CLD"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Ground")
                      .font(.subheadline)
                    Text(viewModel.getCommunicationType(comms: viewModel.comms, type: "GND"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Tower")
                      .font(.subheadline)
                    Text(viewModel.getCommunicationType(comms: viewModel.comms, type: "TWR"))
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
          
          Picker(selection: $viewModel.selectedInfoTab, label: Text("Picker")) {
            ForEach(AirportsScreenInfoTabs.allCases, id: \.id) { tab in
              Text(tab.rawValue)
                .tag(tab)
            }
          }
          .pickerStyle(.segmented)
          AirportScreenInfoTabBuilder(selectedTab: viewModel.selectedInfoTab, airportVM: viewModel)
          Spacer()
        }
        .navigationTitle("\(viewModel.selectedAirport?.airportName ?? "Airport Details")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          TextField("Search Airports...", text: $viewModel.searchText)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .frame(width: 300)
            .onTapGesture {
              textFieldFocused = true
            }
            .popover(isPresented: $textFieldFocused, content: {
              if viewModel.searchText.count > 1 {
                List {
                  ForEach(viewModel.airportSearchResults) { result in
                    Button {
                      viewModel.selectedAirport = SQLiteManager.shared.selectAirport(result.airportIdentifier)
                      viewModel.selectedAirportICAO = result.airportIdentifier
                      textFieldFocused = false
                    } label: {
                      Text("\(result.airportIdentifier) - \(result.airportName)")
                    }
                    .listRowSeparator(.visible)
                  }
                }
                .listStyle(.plain)
                .frame(idealWidth: 300, idealHeight: 300, maxHeight: 500)
              } else {
                EmptyView()
                  .frame(idealWidth: 300, idealHeight: 300)
              }
            })
        }
      }
      
    }
    .onAppear {
      // fetch metar, weather, local weather, etc
      if viewModel.selectedAirportICAO != viewModel.prevICAO {
        viewModel.fetchFaaMetar(icao: viewModel.selectedAirportICAO)
      }
    }
  }
  
}

struct AirportScreenInfoTabBuilder: View {
  let selectedTab: AirportsScreenInfoTabs
  let airportVM: AirportScreenViewModel
  
  @ViewBuilder
  var body: some View {
    switch selectedTab {
    case .freq:
      if airportVM.comms != [] {
        AirportScreenFreqTab(comms: airportVM.comms)
      } else {
        ContentUnavailableView("Frequencies INOP", systemImage: "", description: Text("Select an airport to view frequencies."))
      }
    case .wx:
      AirportScreenWxTab(airportVM: airportVM)
    case .rwy:
      if airportVM.runways != [] {
        AirportScreenRwyTab(runways: airportVM.runways, wx: airportVM.faaMetar)
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

// TODO: fix this ugly screen
struct AirportScreenWxTab: View {
  var airportVM: AirportScreenViewModel
  
  var body: some View {
    @Bindable var airportVM = airportVM
    VStack {
      Button {
        airportVM.fetchWx(for: airportVM.wxSource, type: airportVM.wxType, icao: airportVM.selectedAirportICAO, refresh: true)
      } label: {
        Text("Refresh")
      }
      
      Picker("Weather Source", selection: $airportVM.wxSource) {
        ForEach(WxSources.allCases) { source in
          Text(source.rawValue.uppercased())
            .tag(source)
        }
      }
      .pickerStyle(.segmented)

      Picker("Weather Type", selection: $airportVM.wxType) {
        ForEach(WxTabs.allCases) { tab in
          Text(tab.rawValue)
            .tag(tab)
        }
      }
      .pickerStyle(.segmented)
      
      Text(airportVM.currentWxString)
        .font(.system(size: 14))
    }
    .padding()
    .refreshable {
      guard airportVM.selectedAirportICAO != "" else { return }
//      airportVM.fetchAirportWx(icao: airportVM.selectedAirportICAO)
    }
    .onChange(of: airportVM.wxSource) {
      airportVM.fetchWx(for: airportVM.wxSource, type: airportVM.wxType, icao: airportVM.selectedAirportICAO, refresh: false)
    }
    .onChange(of: airportVM.wxType) {
      airportVM.fetchWx(for: airportVM.wxSource, type: airportVM.wxType, icao: airportVM.selectedAirportICAO, refresh: false)
    }
  }
}

// TODO: Organize Runways, build runway model things?
// TODO: Runway models with wind direction showing?
// TODO: If RVR is less than length of runway, draw line displaying RVR of runway?
struct AirportScreenRwyTab: View {
  let runways: [RunwayTable]?
  let wx: [AirportMETARSchema]?
  
  @State var optimalRunways: [RunwayTable] = []
  @State var longestRunways: [RunwayTable] = []
  
  var body: some View {
    if let runways {
      ScrollView(.vertical) {
        WrappingHStack(models: runways) { runway in
          AirportRunwayView(runway: runway, weather: wx?.first, optimal: isOptimal(runway), longest: isLongest(runway))
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

