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
            .rotationEffect(.degrees(runway.runwayMagneticBearing ?? .zero))
            
            if let windDir = weather?.wdir, let dir = windDir.asInt {
              Image(systemName: "arrow.up")
                .foregroundStyle(.indigo)
                .rotationEffect(.degrees(Double(invertDegree(for: dir))))
                .font(.system(size: 70))
            }
          }
        }
      }
      
      Text("\(String(describing: runway.runwayLength))'")
        .foregroundStyle(longest ? .orange : .secondary)
        .fontWeight(.semibold)
    }
    .popover(isPresented: $popoverPresented, content: {
      List {
        Text("Thresh Elev: \(String(describing: runway.landingThresholdElevation))")
        Text("Width: \(String(describing: runway.runwayWidth))")
        Text("llz: \(String(describing: runway.llzIdentifier))")
        Text("Mag: \(String(describing: runway.runwayMagneticBearing))")
        Text("True: \(String(describing: runway.runwayTrueBearing))")
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
    runway: RunwayTable.mock,
    weather: nil,
    optimal: false,
    longest: false
  )
}
