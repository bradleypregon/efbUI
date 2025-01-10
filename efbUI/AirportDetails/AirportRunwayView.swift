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
    VStack {
      Text(runway.runwayIdentifier)
        .foregroundStyle(longest ? .orange : .secondary)
        .fontWeight(.semibold)
      
      Button {
        popoverPresented.toggle()
      } label: {
        ZStack {
          if optimal {
            RoundedRectangle(cornerRadius: 20)
              .stroke(.vfr, lineWidth: 10)
              .frame(width: 200, height: 200)
          } else {
            RoundedRectangle(cornerRadius: 20)
              .frame(width: 200, height: 200)
          }
          
          ZStack {
            ZStack {
              RoundedRectangle(cornerRadius: 4)
                .stroke(.white, lineWidth: 5)
                .frame(width: 45, height: 190)
              
              Text(runway.runwayIdentifier.split(separator: "RW")[0])
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .offset(y: 80)
            }
            .rotationEffect(.degrees(runway.runwayMagneticBearing))
            
            if let windDir = weather?.wdir, let dir = windDir.asInt {
              Image(systemName: "arrow.up")
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(Double(invertDegree(for: dir))))
                .font(.system(size: 55))
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
      .frame(width: 200, height: 145)
    })
  }
  
  func invertDegree(for heading: Int) -> Int {
    return (heading < 180) ? (heading + 180) : (heading - 180)
  }
  
  func getRunwaySurface() {
    
  }
  
  func getRunwaySurfaceColor() {
    
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AirportRunwayView(runway: .init(areaCode: "", icaoCode: "", airportIdentifier: "", runwayIdentifier: "RW10", runwayLatitude: .zero, runwayLongitude: .zero, runwayGradient: .zero, runwayMagneticBearing: 360, runwayTrueBearing: 010, landingThresholdElevation: 1000, displacedThresholdDistance: 100, thresholdCrossingHeight: 100, runwayLength: 6000, runwayWidth: 200, llzIdentifier: "", llz_mls_gls_category: "", surfaceCode: 5, id: ""), weather: nil, optimal: false, longest: true)
}
