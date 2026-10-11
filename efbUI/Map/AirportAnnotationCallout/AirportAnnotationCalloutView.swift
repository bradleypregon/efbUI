//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct AirportAnnotationCalloutView: View {
  @Environment(AppCoordinator.self) private var appCoordinator
  @Environment(GRDBManager.self) private var grdb
  
  var airport: AirportTable
  
  @State private var currTimeZone: TimeZone = .current
  
  @State private var currWx: [AirportMETARSchema] = []
  @State private var wxCat: WxCategory = .NONE
  
  @State private var comms: [AirportCommunicationTable] = []
  
  @State private var wxString: String?
  
  
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
        do {
          currWx = try await AirportWxAPI().fetchMetar(icao: airport.airportIdentifier)
        } catch {
          print("Error fetching weather for airport")
        }
        wxCat = currWx.first?.fltCat ?? .NONE
      }
      
      ScrollView(.vertical) {
        AirportCalloutInfoView(airport: airport)
        
        GroupBox("Wx") {
          if !currWx.isEmpty {
            Text(currWx[0].rawOb)
              .monospaced()
            Text("Last Updated: \(currWx[0].reportTime)")
              .font(.caption)
          }
        }
        
        AirportCalloutRunwayView(icao: airport.airportIdentifier)
        
        GroupBox("Procedures") {
          Text("Arrivals")
          Text("Departures")
        }
      }
      
      HStack {
        Text("\(String(format: "%.2f", airport.airportRefLat ?? 0)), \(String(format: "%.2f", airport.airportRefLong ?? 0))")
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
    guard let lat = airport.airportRefLat, let long = airport.airportRefLong else { return TimeZone.current }
    let location: CLLocation = .init(latitude: lat, longitude: long)
    
    if let request = MKReverseGeocodingRequest(location: location) {
      let mapitems = try? await request.mapItems
      if let mapitem = mapitems?.first {
        return mapitem.timeZone
      }
    }
    return TimeZone.current
  }
  
  func calculateBounds(radius: Double) -> (CLLocationCoordinate2D, CLLocationCoordinate2D)? {
    guard let latitude = airport.airportRefLat, let longitude = airport.airportRefLong else { return nil }
    
    let earthRadius = 6378.0
    let lat = latitude * Double.pi / 180
    let latRad = radius / earthRadius
    let longRad = radius / (earthRadius * cos(lat))
    let latOffset = latRad * 180 / Double.pi
    let longOffset = longRad * 180 / Double.pi
    
    let ne = CLLocationCoordinate2D(latitude: lat + latOffset, longitude: longitude + longOffset)
    let sw = CLLocationCoordinate2D(latitude: lat - latOffset, longitude: longitude - longOffset)
    
    return (ne, sw)
  }
  
}
