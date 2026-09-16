//
//  AirportRunwayView.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//

import SwiftUI

struct AirportRunwayView: View {
  let runway: RunwayTable
  let weather: AirportMETARSchema?
  let optimal: Bool
  let longest: Bool
  
  @State private var popoverPresented: Bool = false
  
  var body: some View {
    VStack(spacing: 12) {
      Text(runway.runwayIdentifier)
        .foregroundStyle(longest ? .orange : .secondary)
        .fontWeight(.semibold)
      
      Button {
        popoverPresented.toggle()
      } label: {
        ZStack {
          RoundedRectangle(cornerRadius: 32)
            .stroke(optimal ? .vfr : .primary, lineWidth: 8)
            .frame(width: 200, height: 200)
          
          ZStack {
            ZStack {
              Rectangle()
                .fill(.gray)
                .frame(width: 50, height: 180)
              
              VStack {
                ForEach(1...10, id: \.self) { blah in
                  Rectangle()
                    .frame(width: 5, height: 10)
                    .foregroundStyle(.white.opacity(0.5))
                }
              }
              
              Text("`\(runway.runwayIdentifier.split(separator: "RW")[0])`")
                .foregroundStyle(.white)
                .background(.gray)
                .font(.title.bold())
                .offset(y: 70)
            }
            .rotationEffect(.degrees(runway.runwayMagneticBearing))
            
            if let windDir = weather?.wdir, let dir = windDir.asInt {
              Image(systemName: "arrow.up")
                .foregroundStyle(.indigo)
                .rotationEffect(.degrees(Double(invertDegree(for: dir))))
                .font(.system(size: 70))
            }
          }
        }
      }
      
      Text("\(runway.runwayLength)'")
        .foregroundStyle(longest ? .orange : .secondary)
        .fontWeight(.semibold)
    }
    .popover(isPresented: $popoverPresented, content: {
      List {
        Text("Thresh Elev: \(runway.landingThresholdElevation)")
        Text("Width: \(runway.runwayWidth)")
        Text("llz: \(runway.llzIdentifier)")
        Text("Mag: \(runway.runwayMagneticBearing)")
        Text("True: \(runway.runwayTrueBearing)")
      }
      .listStyle(.inset)
      .frame(width: 200, height: 200)
    })
  }
  
  func invertDegree(for heading: Int) -> Int {
    return (heading < 180) ? (heading + 180) : (heading - 180)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AirportRunwayView(
    runway: .init(
      areaCode: "",
      icaoCode: "",
      airportIdentifier: "",
      runwayIdentifier: "RW10",
      runwayLatitude: .zero,
      runwayLongitude: .zero,
      runwayGradient: .zero,
      runwayMagneticBearing: 010,
      runwayTrueBearing: 010,
      landingThresholdElevation: 1000,
      displacedThresholdDistance: 100,
      thresholdCrossingHeight: 100,
      runwayLength: 6901,
      runwayWidth: 200,
      llzIdentifier: "",
      llz_mls_gls_category: "",
      surfaceCode: 5,
      id: ""
    ),
    weather: .init(metarID: nil, icaoID: nil, receiptTime: nil, obsTime: nil, reportTime: nil, temp: nil, dewp: nil, wdir: .int(010), wspd: nil, wgst: nil, visib: nil, altim: nil, slp: nil, qcField: nil, wxString: nil, presTend: nil, maxT: nil, minT: nil, maxT24: nil, minT24: nil, precip: nil, pcp3hr: nil, pcp6hr: nil, pcp24hr: nil, snow: nil, vertVis: nil, metarType: nil, rawOb: nil, mostRecent: nil, lat: nil, lon: nil, elev: nil, prior: nil, name: nil, clouds: []),
    optimal: false,
    longest: false
  )
}
