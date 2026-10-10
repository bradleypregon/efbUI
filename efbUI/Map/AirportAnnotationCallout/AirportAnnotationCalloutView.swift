//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation
import MapKit

// May still want this to be in Navigation Sidebar?

struct AirportAnnotationCalloutView: View {
  @Environment(AppCoordinator.self) private var appCoordinator
  @Environment(GRDBManager.self) private var grdb
  
  var airport: AirportTable
  
  @State private var currTimeZone: TimeZone = .current
  @State private var currWx: [AirportMETARSchema] = []
  @State private var wxCat: WxCategory = .NONE
  @State private var comms: [AirportCommunicationTable] = []
  @State private var wxString: String?
  @State private var bestRwy: RunwayTable?
  
  
  var body: some View {
    VStack {
      GroupBox {
        HStack {
          Text(airport.airportIdentifier)
          Spacer()
            .frame(width:8)
          Circle()
            .fill(wxCat.color)
            .frame(width: 12, height: 12)
          Text(wxCat.rawValue)
            .foregroundStyle(wxCat.color)
        }
        .fontWeight(.semibold)
      }
      .task(id: wxCat) {
        // Calculate weather category
        do {
          currWx = try await AirportWxAPI().fetchMetar(icao: airport.airportIdentifier)
        } catch {
          print("Error fetching weather for airport")
        }
        wxCat = currWx.first?.fltCat ?? .NONE
      }
      
      ScrollView(.vertical) {
        GroupBox("Wx") {
          if !currWx.isEmpty {
            Text(currWx[0].rawOb)
              .monospaced()
            Text("Last Updated: \(currWx[0].reportTime)")
              .font(.caption)
          }
        }
        
        // TWR/Vatsim CTAF
        GroupBox("Info") {
          Grid(alignment: .leading) {
            GridRow {
              Text("TWR")
                .font(.subheadline)
              Text(getCommunicationType(comms: comms, type: "TWR"))
                .fontWeight(.semibold)
            }
            GridRow {
              Text("\(getATIS(comms: comms).first?.communicationType ?? "ATI n/a")")
                .font(.subheadline)
              Text("\(String(format: "%.3f", getATIS(comms: comms).first?.communicationFrequency ?? .zero))")
                .fontWeight(.semibold)
            }
            GridRow {
              Text("ELEV")
                .font(.subheadline)
              Text("\(airport.elevation ?? .zero)'")
                .fontWeight(.semibold)
            }
          }
        }
        .task(id: comms) {
          do {
            comms = try await grdb.fetchCommunications(for: airport.airportIdentifier)
            return
          } catch {
            print("Error fetching Comms for \(airport.airportIdentifier)")
          }
          comms = []
        }
        
        // Calculate best runway based on winds
        GroupBox("Best Rwy") {
          if let rwy = bestRwy {
            Text(rwy.runwayIdentifier)
          } else {
            Text("Best Rwy N/A")
          }
        }
        .task(id: bestRwy) {
          // Fetch runways for icao
          bestRwy = RunwayTable.mock
        }
        
        GroupBox("Procedures") {
          Text("Arrivals")
          Text("Departures")
        }
      }
      
      HStack {
        Text("\(String(format: "%.2f", airport.airportRefLat ?? .zero)), \(String(format: "%.2f", airport.airportRefLong ?? .zero))")
        .font(.caption2)
        .foregroundStyle(.gray)
        
        Button("View Airport") {
          appCoordinator.openAirport(airport.airportIdentifier)
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
      }
      .frame(alignment: .center)
      
    }
    .padding()
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
  
  func getTimeZone() async -> TimeZone? {
    guard let lat = airport.airportRefLat, let long = airport.airportRefLong else { return nil }
    let location = CLLocation(latitude: lat, longitude: long)
    
    if let request = MKReverseGeocodingRequest(location: location) {
      let mapitems = try? await request.mapItems
      if let mapitem = mapitems?.first {
        return mapitem.timeZone
      }
    }
    return TimeZone.current
  }
  
  func calculateBounds(radius: Double) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
    let earthRadius = 6378.0
    let lat = airport.airportRefLat ?? .zero * Double.pi / 180
    let latRad = radius / earthRadius
    let longRad = radius / (earthRadius * cos(lat))
    let latOffset = latRad * 180 / Double.pi
    let longOffset = longRad * 180 / Double.pi
    
    let ne = CLLocationCoordinate2D(latitude: airport.airportRefLat ?? .zero + latOffset, longitude: airport.airportRefLong ?? .zero + longOffset)
    let sw = CLLocationCoordinate2D(latitude: airport.airportRefLat ?? .zero - latOffset, longitude: airport.airportRefLong ?? .zero - longOffset)
    
    return (ne, sw)
  }
  
  func getCommunicationType(comms: [AirportCommunicationTable], type: String) -> String {
    if comms == [] { return "n/a" }
    if let freq = comms.first(where: { $0.communicationType == type && $0.frequencyUnits == "V"} )?.communicationFrequency?.string {
      return freq
    } else {
      return "n/a"
    }
  }
  
  func getATIS(comms: [AirportCommunicationTable]) -> [AirportCommunicationTable] {
    let types = ["ATI", "AWO", "ASO", "AWI", "AWS"]
    guard !comms.isEmpty else { return [] }
    
    let filter = comms.filter { $0.frequencyUnits == "V" && types.contains($0.communicationType ?? "") }
    guard !filter.isEmpty else { return [] }
    
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
      if let a = a.communicationType, let b = b.communicationType {
        let rankA = ranking[a] ?? Int.max
        let rankB = ranking[b] ?? Int.max
        return rankA < rankB
      }
      return false
    }
  }
}
