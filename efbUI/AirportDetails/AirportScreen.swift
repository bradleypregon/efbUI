//
//  AirportScreen.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/21.
//

import SwiftUI
import CoreLocation


enum AirportsScreenInfoTabs: String, Identifiable, CaseIterable {
  case freq, wx, rwy, chart, localwx
  var id: Self { self }
}

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
  @State private var airportDetailViewModel = AirportDetailViewModel.shared
  @State private var textFieldFocused: Bool = false
  private var grid = [GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
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
                    if let wx = airportDetailViewModel.airportWx {
                      Text(airportDetailViewModel.calculateWxCategory(wx: wx).rawValue)
                        .fontWeight(.semibold)
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
                  GridRow {
                    Text("Fuel")
                      .font(.subheadline)
                    Text("Placeholder")
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Proc Avail")
                      .font(.subheadline)
                    Text("Placeholder")
                      .fontWeight(.semibold)
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
            ForEach(AirportsScreenInfoTabs.allCases) { tab in
              Text(tab.rawValue.capitalized)
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
                      
//                      if let airport = airportScreenViewModel.selectedAirport {
//                        DispatchQueue.main.async {
//                          airportScreenViewModel.queryAirportData(airport: airport)
//                        }
//                      }
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
      if airportVM.selectedAirportComms != nil {
        AirportScreenFreqTab(comms: airportVM.selectedAirportComms)
      } else {
        ContentUnavailableView("Airport Frequencies Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view frequencies."))
      }
    case .wx:
      if airportVM.airportWx != nil {
        AirportScreenWxTab(wx: airportVM.airportWx)
      } else {
        ContentUnavailableView("Airport Weather Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view weather."))
      }
    case .rwy:
      if airportVM.selectedAirportRunways != nil {
        AirportScreenRwyTab(runway: airportVM.selectedAirportRunways)
      } else {
        ContentUnavailableView("Airport Runways Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view runways."))
      }
    case .chart:
      if airportVM.selectedAirportCharts != nil {
        AirportScreenChart(charts: airportVM.selectedAirportCharts)
      } else {
        ContentUnavailableView("Airport Charts Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view charts."))
      }
    case .localwx:
      if airportVM.osmWeatherResults != nil {
        AirportScreenLocalWxTab(localwx: airportVM.osmWeatherResults)
      } else {
        ContentUnavailableView("Airport Local Weather Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view local weather."))
      }
    }
  }
}

struct AirportScreenFreqTab: View {
  let comms: [AirportCommunicationTable]?
  
  var body: some View {
    if let comms {
      ScrollView(.vertical) {
        ForEach(comms, id:\.self) { comm in
          VStack {
            HStack {
              Text(comm.communicationType)
              Text("\(comm.communicationFrequency.string)")
              Text(comm.callsign)
            }
          }
        }
      }
    }
  }
}

struct AirportScreenWxTab: View {
  let wx: AirportMetarInfo?
  
  var body: some View {
    if let wx = wx?.first {
      ScrollView(.vertical) {
        VStack {
          Text("METAR")
          Text(wx.rawOb ?? "METAR Unavailable")
          // TODO: Split TAF on each line. Line starts with 'FM[day][hour][minute]' exc. first line
          Text("TAF")
          Text(wx.rawTaf ?? "TAF Unavailable")
        }
      }
    }
  }
}

struct AirportScreenRwyTab: View {
  let runway: [RunwayTable]?
  
  var body: some View {
    if let runway {
      ScrollView(.vertical) {
        ForEach(runway, id:\.runwayIdentifier) { runway in
          VStack {
            HStack {
              // TODO: Convert surfaceCode to something friendly
              // TODO: formatting
              Text(runway.runwayIdentifier)
              Text("\(runway.runwayMagneticBearing)")
              Text("\(runway.runwayTrueBearing)")
              Text("\(runway.runwayLength)")
              Text("\(runway.runwayWidth)")
              Text("\(runway.surfaceCode)")
            }
          }
        }
      }
    }
  }
}

struct AirportScreenChart: View {
  let charts: DecodedArray<AirportChartAPISchema>?
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [AirportDetail] = []
  @State private var selectedChart: AirportDetail?
  
  var body: some View {
    if let charts = charts?.first {
      NavigationSplitView(columnVisibility: $columnVisibility) {
        // sidebar
        List {
          /// Starred Charts
          DisclosureGroup("Starred") {
            ForEach(starred, id: \.chartName) { chart in
              // TODO: swipe to remove chart
              Text(chart.chartName)
            }
          }
          
          /// General Charts
          DisclosureGroup("General") {
            ForEach(charts.general, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
              }
            }
          }
          
          /// Departure Charts
          DisclosureGroup("Departure") {
            ForEach(charts.dp, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
              }
            }
          }
          
          /// Arrival Charts
          DisclosureGroup("Arrival") {
            ForEach(charts.star, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
              }
            }
          }
          
          /// Approach Charts
          DisclosureGroup("Approach") {
            ForEach(charts.capp, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
              }
            }
          }
        }
        .listStyle(.sidebar)
      } detail: {
        // detail
        // chart viewer
        if let pdfPath = selectedChart?.pdfPath, let url = URL(string: pdfPath) {
          PDFKitView(url: url)
        } else {
          Text("PDF will show up here")
        }
      }
    }
    
  }
}

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


#Preview {
  AirportScreen()
}

