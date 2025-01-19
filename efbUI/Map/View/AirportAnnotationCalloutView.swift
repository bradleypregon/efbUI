//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation

struct AirportAnnotationCalloutView: View {
  @Environment(AirportScreenViewModel.self) private var airportVM
  
  @Binding var selectedTab: efbTab
  var airport: AirportTable
  @State private var vm = AirportDetails()
  
  @State private var currentTime = Date()
  @State private var currTimeInt = Date().timeIntervalSince1970
  @State private var timeIntervals: [Double] = []
  @State private var currTimeZone: TimeZone = .current
  
  var body: some View {
    VStack {
      // Header
      HStack {
        Text(!airport.airportIdentifier.isEmpty ? airport.airportIdentifier : airport.id)
        Text(airport.airportName)
      }
      .fontWeight(.semibold)
      
      ScrollView(.vertical) {
        GroupBox("Info") {
          Grid(alignment: .leading) {
            GridRow {
              Text("TWR")
                .font(.subheadline)
              Text(vm.getCommunicationType(comms: vm.comms, type: "TWR"))
                .fontWeight(.semibold)
            }
            GridRow {
              Text("\(vm.getATIS(comms: vm.comms).first?.communicationType ?? "ATI n/a")")
                .font(.subheadline)
              Text("\(String(format: "%.3f", vm.getATIS(comms: vm.comms).first?.communicationFrequency ?? .zero))")
                .fontWeight(.semibold)
            }
            GridRow {
              Text("ELEV")
                .font(.subheadline)
              Text("\(airport.elevation)'")
                .fontWeight(.semibold)
            }
          }
        }
        GroupBox("Weather") {
          VStack {
            HStack {
              Text(vm.wxCategory.rawValue)
                .fontWeight(.semibold)
                .foregroundStyle(vm.wxCategoryColor(for: vm.wxCategory))
              Button {
                Task {
                  await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: true)
                }
              } label: {
                Text("Refresh")
              }
              .clipShape(Capsule())
            }
            
            Divider()
            
            VStack {
              Picker("Weather Source", selection: $vm.wxSource) {
                ForEach(WxSources.allCases) { source in
                  Text(source.rawValue.uppercased())
                }
              }
              Picker("Weather Type", selection: $vm.wxType) {
                ForEach(WxTabs.allCases) { tab in
                  Text(tab.rawValue)
                }
              }
            }
            .pickerStyle(.segmented)
            
            // TODO: Change step and values?
            if vm.wxSource == .faa && vm.wxType == .metar {
              Slider(value: $currTimeInt, in: (currentTime.timeIntervalSince1970-43200)...(currentTime.timeIntervalSince1970), step: 900) { _ in }
              HStack {
                Text(getTime(currTimeInt))
                  .font(.caption)
                Button {
                  print("Get updated metar")
                } label: {
                  Image(systemName: "arrow.clockwise.circle.fill")
                }
              }
              
              if (vm.currentWxString == "") {
                // TODO: add Setting for closest METAR station radius
                if let field = vm.closestField(to: CLLocationCoordinate2DMake(airport.airportRefLat, airport.airportRefLong), fields: vm.nearestWxStrings) {
                  Text(field.rawOb ?? "")
                }
              }
            }
            
            Text(vm.currentWxString)
              .font(.system(size: 14))
          }
          .onChange(of: vm.wxSource.rawValue) {
            Task {
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: false)
            }
          }
          .onChange(of: vm.wxType.rawValue) {
            Task {
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: false)
            }
          }
        }
        GroupBox("Runways") {
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 4) {
            ForEach(vm.runways, id: \.self) { runway in
              Text(runway.runwayIdentifier)
            }
          }
        }
        
        if let vatsim = vm.vatsimInfo {
          GroupBox("Vatsim") {
            Grid(alignment: .leading, verticalSpacing: 4) {
              ForEach(vatsim.data.stations, id: \.self) { station in
                GridRow {
                  Text(station.ctaf ? "\(station.name) CTAF" : station.name)
                    .font(.caption2)
                    .fontWeight(station.ctaf ? .semibold : .regular)
                }
                GridRow {
                  Text(station.callsign)
                  Text(station.frequency)
                    .fontWeight(.semibold)
                }
              }
            }
          }
        }
      }
      HStack {
        VStack {
          Text("\(String(format: "%.4f", airport.airportRefLat))")
          Text("\(String(format: "%.4f", airport.airportRefLong))")
        }
        .font(.caption2)
        .foregroundStyle(.gray)
        
        Button {
          airportVM.selectedAirportICAO = airport.airportIdentifier
          selectedTab = .airports
        } label: {
          Text("View Airport")
            .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, alignment: .center)
      }
    }
    .padding()
    .task {
      if airport.airportIdentifier != vm.prevICAO {
        await vm.fetchFaaMetar(icao: airport.airportIdentifier)
      }
      await vm.fetchAirportDetails(icao: airport.airportIdentifier)
      
      self.currTimeZone = await getTimeZone()
      
      let bounds = calculateBounds(radius: 40)
      await vm.fetchBBoxMetar(ne: bounds.0, sw: bounds.1)
//      let currTimeInterval = currentTime.timeIntervalSince1970
//      timeIntervals.insert(currTimeInterval, at: 0)
//      createTimeIntervals(timeInterval: currTimeInterval, timeInterval12hr: currTimeInterval - 43200)
    }
    .onDisappear {
      
    }
  }
  
  func getTime(_ timeInterval: Double) -> String {
    let date = getDate(timeInterval: timeInterval)
    let localTime = getLocalTime(date)
    let zTime = getZuluTime(date)
    
    return "\(localTime) - \(zTime)Z"
  }
  
  func getZuluTime(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "HHmm"
    df.timeZone = TimeZone(identifier: "UTC")
    return df.string(from: date)
  }
  
  func getLocalTime(_ date: Date) -> String {
//    formatted(date: date)
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = currTimeZone
    df.timeStyle = .short
    return df.string(from: date)
  }
  
  func formatted(date: Date) {
    let df = DateFormatter()
    df.dateFormat = "yyyyMMdd_HHmm"
    df.timeZone = TimeZone(identifier: "UTC")
    let str = df.string(from: date)
    print("\(str)Z")
  }
  
  func getDate(timeInterval: Double) -> Date {
    return Date(timeIntervalSince1970: timeInterval)
  }
  
  func getTimeZone() async -> TimeZone {
    let location = CLLocation(latitude: airport.airportRefLat, longitude: airport.airportRefLong)
    return await withCheckedContinuation { cont in
      CLGeocoder().reverseGeocodeLocation(location) { places, err in
        if let tz = places?.first?.timeZone {
          cont.resume(returning: tz)
        } else {
          cont.resume(returning: .current)
        }
      }
    }
  }
  
  func calculateBounds(radius: Double) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
    let earthRadius = 6378.0
    let lat = airport.airportRefLat * Double.pi / 180
    let latRad = radius / earthRadius
    let longRad = radius / (earthRadius * cos(lat))
    let latOffset = latRad * 180 / Double.pi
    let longOffset = longRad * 180 / Double.pi
    
    let ne = CLLocationCoordinate2D(latitude: airport.airportRefLat + latOffset, longitude: airport.airportRefLong + longOffset)
    let sw = CLLocationCoordinate2D(latitude: airport.airportRefLat - latOffset, longitude: airport.airportRefLong - longOffset)
    
    return (ne, sw)
  }
  
  // MARK: My first recursive function in years
  func createTimeIntervals(timeInterval: Double, timeInterval12hr: Double) {
    if (timeInterval > timeInterval12hr) {
      let dec = (timeInterval - 900)
      timeIntervals.insert(dec.rounded(), at: 0)
      createTimeIntervals(timeInterval: dec, timeInterval12hr: timeInterval12hr)
    }
  }
}
