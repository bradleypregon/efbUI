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
                      selectedTab = 1
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
        ContentUnavailableView("Airport Frequencies Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view frequencies."))
      }
    case .wx:
      AirportScreenWxTab(metar: airportVM.airportWxMetar, taf: airportVM.airportWxTAF)
    case .rwy:
      if airportVM.selectedAirportRunways != nil {
        AirportScreenRwyTab(runway: airportVM.selectedAirportRunways, wx: airportVM.airportWxMetar)
      } else {
        ContentUnavailableView("Airport Runways Unavailable", systemImage: "airplane.circle", description: Text("Select an airport to view runways."))
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
  let taf: AirportTAFSchema?
  
  var body: some View {
    ScrollView {
      if let metar = metar?.first, let ob = metar.rawOb {
        VStack {
          Text("METAR")
            .font(.largeTitle)
          Text(ob)
        }
      } else {
        ContentUnavailableView("METAR Unavailable", systemImage: "airplane.circle", description: Text("METAR may be unavailable or an internal fault happened."))
      }
      if let taf = taf?.first {
        VStack {
          Text("TAF")
            .font(.largeTitle)
          Text(taf.rawTAF ?? "")
//          ForEach(splitTAF(taf.rawTAF ?? ""), id:\.self) { taf in
//            Text(taf)
//          }
        }
      } else {
        ContentUnavailableView("TAF Unavailable", systemImage: "airplane.circle", description: Text("TAF may be unavailable or an internal fault happened."))
      }
    }
  }
  
//  func splitTAF(_ taf: String) -> [String] {
//    if taf == "" { return [""] }
//    var substrings: [String] = []
//    
//    do {
//      let pattern = #"(\bTEMPO\b|\bBECMG\b|\bFM\d{6}\b)"#
//      let regex = try NSRegularExpression(pattern: pattern, options: [])
//      let matches = regex.matches(in: taf, options: [], range: NSRange(location: 0, length: taf.utf16.count))
//      
//      var start = taf.startIndex
//      for match in matches {
//        let range = Range(match.range, in: taf)!
//        let substring = String(taf[start..<range.lowerBound])
//        let string = "\(substring) \(String(taf[range]))"
//        substrings.append(string)
//        start = range.upperBound
//      }
//      substrings.append(String(taf[start...]))
//      return substrings
//    } catch {
//      print("Error using RegEx on TAF: \(error)")
//      return [""]
//    }
//  }
}

// TODO: Organize Runways, build runway model things?
// TODO: Runway models with wind direction showing?
// TODO: If RVR is less than length of runway, draw line displaying RVR of runway?
struct AirportScreenRwyTab: View {
  let runway: [RunwayTable]?
  let wx: AirportMETARSchema?
  
  var body: some View {
    if let runway {
      ScrollView(.vertical) {
        ForEach(runway, id:\.runwayIdentifier) { runway in
          AirportRunway(runway: runway, weather: wx)
//          VStack {
//            HStack {
//              Text(runway.runwayIdentifier)
//              Text("\(runway.runwayMagneticBearing)")
//              Text("\(runway.runwayTrueBearing)")
//              Text("\(runway.runwayLength)")
//              Text("\(runway.runwayWidth)")
//              Text("\(runway.surfaceCode)")
//            }
//          }
        }
      }
    }
  }
}

struct AirportRunway: View {
  let runway: RunwayTable
  let weather: AirportMETARSchema?
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .background(.gray)
      VStack {
        Text(runway.runwayIdentifier)
        ZStack {
          Rectangle()
            .stroke(.white)
            .fill(.asphalt)
            .rotationEffect(.degrees(getRunwayHeading(heading: runway.runwayMagneticBearing)-90.0), anchor: .center)
//          if weather != nil, let dir = weather?.first?.wdir {
//            Image("")
//              .foregroundStyle(.blue)
//              .rotationEffect(.degrees(Double(dir)))
//          }
        }
        .frame(maxWidth: 75)
        Text(runway.runwayLength.string)
      }
    }
  }
  
  func getRunwaySurface() {
    
  }
  
  func getRunwaySurfaceColor() {
    
  }
  
  func getRunwayHeading(heading: Double) -> Double {
    if heading < 180 { return heading }
    return heading-180
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


#Preview {
  AirportScreen(selectedTab: .constant(0))
}

