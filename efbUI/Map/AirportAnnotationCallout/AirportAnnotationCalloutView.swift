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
  @Environment(ToastManager.self) private var toastMan
  
  var airport: AirportTable
  
  @State private var currTimeZone: TimeZone = .current
  
  @State private var currWx: [AirportMETARSchema] = []
  @State private var wxCat: WxCategory = .NONE
  
  @State private var weatherLoading: Bool = true
  
  private let relativeDate: RelativeDateTimeFormatter = {
    let df = RelativeDateTimeFormatter()
    df.unitsStyle = .full
    return df
  }()
  
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
          
          Button {
            toastMan.push(icon: "", title: "Hell yeah brother favorite airport here")
            
          } label: {
            Image(systemName: "star.fill")
              .frame(width: 20, height: 20)
          }
          .buttonStyle(.glass)
        }
        .fontWeight(.semibold)
      }
      
      .task(id: wxCat) {
        defer { weatherLoading = false }
        do {
          currWx = try await AirportWxAPI().fetchMetar(icao: airport.airportIdentifier)
        } catch {
          print("Error fetching weather for airport")
        }
        wxCat = currWx.first?.fltCat ?? .NONE
      }
      
      ScrollView(.vertical) {
        AirportCalloutInfoView(airport: airport)
        
        GroupBox("Weather") {
          if !currWx.isEmpty {
            AirportCalloutWxView(currWx: currWx[0])
          }
        }
        
        GroupBox("Best Runways") {
          if !weatherLoading {
            let wdir = currWx.first?.wdir?.asDouble ?? nil
            AirportCalloutRunwayView(icao: airport.airportIdentifier, windDir: wdir)
          } else {
            EmptyView()
          }
        }
        
        GroupBox("Procedures") {
          Text("SIDs")
          Text("STARs")
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

/*
 Procedures
 /* Deprecated, use MapViewAnnotation with LongPressGesture
  .popover(item: $mapPopoverSelectedAirport, attachmentAnchor: PopoverAttachmentAnchor.point(mapPopoverSelectedPoint)) { airport in
  let sids = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_sids")
  let stars = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_stars")
  VStack {
  Text(airport.name)
  Button {
  print("View Airport (INOP)")
  } label: {
  Text("View Airport")
  }
  Menu("View Procedures") {
  if (!sids.isEmpty) {
  Button {
  let filteredSIDs = sids.filter{!$0.transitionIdentifier.starts(with: "RW") && $0.transitionIdentifier != "ALL" }
  let grouped = Dictionary(grouping: filteredSIDs, by: { $0.procedureIdentifier })
  mapViewModel.sidRoute = Array(grouped.values)
  mapViewModel.displaySID.toggle()
  } label: {
  Text("View SIDs")
  }
  }
  if (!stars.isEmpty) {
  Button {
  let filteredSTARs = stars.filter{!$0.transitionIdentifier.starts(with: "RW") && $0.transitionIdentifier != "ALL" }
  let grouped = Dictionary(grouping: filteredSTARs, by: { $0.procedureIdentifier })
  mapViewModel.starRoute = Array(grouped.values)
  mapViewModel.displaySTAR.toggle()
  } label: {
  Text("View STARs")
  }
  }
  }
  }
  .frame(idealWidth: 150, idealHeight: 300)
  } */
 */
