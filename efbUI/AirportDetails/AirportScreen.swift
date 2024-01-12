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
  @State private var airportScreenViewModel = AirportDetailViewModel.shared
  @State private var isShowingPopover = false
  private var grid = [GridItem(.flexible()), GridItem(.flexible())]
  
  var body: some View {
    NavigationStack {
      ZStack {
        VStack(spacing: 30) {
          if airportScreenViewModel.selectedAirport != nil {
            HStack {
              Grid(alignment: .leading) {
                GridRow {
                  Text(airportScreenViewModel.cityServed)
                }
                GridRow {
                  Text(airportScreenViewModel.formatAirportCoordinates(lat: airportScreenViewModel.selectedAirport?.airportRefLat ?? .zero, long: airportScreenViewModel.selectedAirport?.airportRefLong ?? .zero))
                }
                GridRow {
                  AirportSunriseSunsetView(weather: airportScreenViewModel.osmWeatherResults)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 20)
              HStack {
                Grid(alignment: .leading) {
                  GridRow {
                    Text("Flight category")
                      .font(.subheadline)
                    Text("VFR")
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Elevation")
                      .font(.subheadline)
                    Text("\(airportScreenViewModel.selectedAirport?.elevation ?? .zero)'")
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Fuel")
                      .font(.subheadline)
                    Text("Jet A, 100LL")
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Proc Avail")
                      .font(.subheadline)
                    Text("ILS, GPS, LOC")
                      .fontWeight(.semibold)
                  }
                }
                Grid(alignment: .leading) {
                  GridRow {
                    Text("ATIS")
                      .font(.subheadline)
                    Text(airportScreenViewModel.getCommunicationType(comms: airportScreenViewModel.selectedAirportComms, type: "ATI"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Clearance")
                      .font(.subheadline)
                    Text(airportScreenViewModel.getCommunicationType(comms: airportScreenViewModel.selectedAirportComms, type: "CLD"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Ground")
                      .font(.subheadline)
                    Text(airportScreenViewModel.getCommunicationType(comms: airportScreenViewModel.selectedAirportComms, type: "GND"))
                      .fontWeight(.semibold)
                  }
                  GridRow {
                    Text("Tower")
                      .font(.subheadline)
                    Text(airportScreenViewModel.getCommunicationType(comms: airportScreenViewModel.selectedAirportComms, type: "TWR"))
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
          
          Picker(selection: $airportScreenViewModel.selectedInfoTab, label: Text("Picker")) {
            ForEach(AirportsScreenInfoTabs.allCases) { tab in
              Text(tab.rawValue.capitalized)
            }
          }
          .pickerStyle(.segmented)
          AirportScreenInfoTabBuilder(selectedTab: airportScreenViewModel.selectedInfoTab, airportVM: airportScreenViewModel)
          Spacer()
        }
        .navigationTitle("\(airportScreenViewModel.selectedAirport?.airportName ?? "Airport Details")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          TextField("Search Airports...", text: $airportScreenViewModel.searchText)
            .textFieldStyle(.roundedBorder)
          // TODO: Find better way to handle tap gesture to reveal popover
            .onTapGesture {
              if !isShowingPopover {
                isShowingPopover = true
              }
            }
            .frame(width: 300)
            .popover(isPresented: $isShowingPopover, content: {
              if airportScreenViewModel.searchText != "" {
                List {
                  ForEach(airportScreenViewModel.airportSearchResults) { result in
                    Button {
                      airportScreenViewModel.selectedAirport = SQLiteManager.shared.selectAirport(result.airportIdentifier)
                      airportScreenViewModel.selectedAirportICAO = result.airportIdentifier
                      
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
        AirportScreenFreqTab()
      } else {
        ContentUnavailableView("Airport Frequencies Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view frequencies."))
      }
    case .wx:
      if airportVM.airportWx != nil {
        AirportScreenWxTab()
      } else {
        ContentUnavailableView("Airport Weather Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view weather."))
      }
    case .rwy:
      if airportVM.selectedAirportRunways != nil {
        AirportScreenRwyTab()
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
        AirportScreenLocalWxTab()
      } else {
        ContentUnavailableView("Airport Local Weather Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view local weather."))
      }
    }
  }
}

struct AirportScreenFreqTab: View {
  var body: some View {
    Text("Freq")
  }
}

struct AirportScreenWxTab: View {
  var body: some View {
    Text("Wx")
  }
}

struct AirportScreenRwyTab: View {
  var body: some View {
    Text("Rwy")
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
                  // starred.contains(chart) ? remove chart : add chart
//                  starred.contains(chart) ? print("removeChart") : starred.append(chart)
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  // starred.contains(chart) ? star.fill : star
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
                .background(.blue)
                .clipShape(Capsule())
              }
            }
          }
          
          /// Departure Charts
          DisclosureGroup("Departure") {
            ForEach(charts.dp, id: \.chartName) { chart in
              Text(chart.chartName)
            }
          }
          
          /// Arrival Charts
          DisclosureGroup("Arrival") {
            ForEach(charts.star, id: \.chartName) { chart in
              Text(chart.chartName)
            }
          }
          
          /// Approach Charts
          DisclosureGroup("Approach") {
            ForEach(charts.capp, id: \.chartName) { chart in
              Text(chart.chartName)
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
  var body: some View {
    Text("Local Wx")
  }
}

/*
 AirportChartAPISchema(
 airport: "KDSM",
 general: [EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "70000", chartCode: "APD", chartName: "AIRPORT DIAGRAM", pdfName: "00117AD.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117AD.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "10700", chartCode: "HOT", chartName: "HOT SPOT", pdfName: "NC3HOTSPOT.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/NC3HOTSPOT.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "10100", chartCode: "MIN", chartName: "TAKEOFF MINIMUMS", pdfName: "NC3TO.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/NC3TO.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "10200", chartCode: "MIN", chartName: "ALTERNATE MINIMUMS", pdfName: "NC3ALT.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/NC3ALT.PDF")],
 dp: [EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "90100", chartCode: "DP", chartName: "DES MOINES ONE", pdfName: "00117DESMOINES.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117DESMOINES.PDF")],
 star: [], 
 capp: [EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "50750", chartCode: "IAP", chartName: "ILS OR LOC RWY 05", pdfName: "00117IL5.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117IL5.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "50750", chartCode: "IAP", chartName: "ILS OR LOC RWY 13", pdfName: "00117IL13.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117IL13.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "50750", chartCode: "IAP", chartName: "ILS OR LOC RWY 31", pdfName: "00117IL31.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117IL31.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "51125", chartCode: "IAP", chartName: "ILS RWY 31 (SA CAT I)", pdfName: "00117I31SAC1.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117I31SAC1.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "51600", chartCode: "IAP", chartName: "ILS RWY 31 (CAT II - III)", pdfName: "00117I31C2_3.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117I31C2_3.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "53525", chartCode: "IAP", chartName: "RNAV (GPS) RWY 05", pdfName: "00117R5.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117R5.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "53525", chartCode: "IAP", chartName: "RNAV (GPS) RWY 13", pdfName: "00117R13.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117R13.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "53525", chartCode: "IAP", chartName: "RNAV (GPS) RWY 23", pdfName: "00117R23.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117R23.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "53525", chartCode: "IAP", chartName: "RNAV (GPS) RWY 31", pdfName: "00117R31.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117R31.PDF"), EFB.AirportDetail(state: "IA", stateFull: "IOWA", city: "DES MOINES", volume: "NC-3", airportName: "DES MOINES INTL", military: "N", faaIdent: "DSM", icaoIdent: "KDSM", chartSeq: "55800", chartCode: "IAP", chartName: "VOR RWY 23", pdfName: "00117V23.PDF", pdfPath: "https://charts.aviationapi.com/AIRAC_231228/00117V23.PDF")])
 */


#Preview {
  AirportScreen()
}

