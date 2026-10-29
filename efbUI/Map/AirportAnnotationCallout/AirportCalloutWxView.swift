//
//  AirportCalloutWxView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/18/26.
//

import SwiftUI

struct AirportCalloutWxView: View {
  let currWx: AirportMETARSchema
  
  let relativeDateFormat: RelativeDateTimeFormatter = {
    let df = RelativeDateTimeFormatter()
    df.unitsStyle = .abbreviated
    return df
  }()
  
  var body: some View {
    let interval: TimeInterval = TimeInterval(currWx.obsTime)
    
    Text(currWx.rawOb)
      .monospaced()

    HStack {
      Text("Obs: \(Date(timeIntervalSince1970: interval).formatted(date: .numeric, time: .shortened))")
      
      Text(relativeDateFormat.localizedString(for: Date(timeIntervalSince1970: interval), relativeTo: Date()))
        .foregroundStyle(colorForTimeInterval(interval))
    }
    .fontWeight(.semibold)
    .font(.caption)
  }
  
  /**
   Return Color associated with TimeInterval for METAR Reports
   
   1. 30 minutes or less: Green
   2. 1.5h - 30m: Yellow
   3. 1.5h or older: Red
   */
  private func colorForTimeInterval(_ interval: TimeInterval) -> Color {
    let rel = Date().timeIntervalSince1970 - interval
    
    let minute: TimeInterval = 60 // seconds
    let halfHour: TimeInterval = minute * 30 // 60 seconds * 30
    let hourAndHalf: TimeInterval = halfHour * 3
    
    switch rel {
    case ...halfHour:
      return .grass
    case halfHour..<hourAndHalf:
      return .warning
    default:
      return .error
    }
  }
}

#Preview {
  AirportCalloutWxView(currWx: .init(
    icaoId: "KJFK",
    receiptTime: Date(),
    obsTime: Int(Date().timeIntervalSince1970),
    reportTime: Date(),
    temp: 18.2,
    dewp: 12.3,
    wdir: .int(220),
    wspd: 7,
    wgst: 12,
    visib: .string("10+"),
    altim: 1013.2,
    slp: 1011.4,
    wxString: "RA BR",
    presTend: nil,
    maxT: 19.0,
    minT: 11.0,
    maxT24: nil,
    minT24: nil,
    precip: 0.1,
    pcp3hr: 0.0,
    pcp6hr: nil,
    pcp24hr: nil,
    snow: nil,
    vertVis: nil,
    metarType: "METAR",
    rawOb: "METAR KJFK 121651Z 22007G12KT 10SM RA BR SCT025 BKN040 18/12 A2993 RMK AO2",
    lat: 40.6413,
    lon: -73.7781,
    elev: 13,
    name: "John F Kennedy Intl",
    clouds: [AirportMetarInfoClouds(cover: "SCT", base: 2500, top: nil), AirportMetarInfoClouds(cover: "BKN", base: 4000, top: nil)],
    fltCat: .MVFR
  ))
}
