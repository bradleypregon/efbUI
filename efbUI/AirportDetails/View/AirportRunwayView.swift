//
//  AirportRunwayView2.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/27/26.
//

import SwiftUI

struct RunwayTableMod {
  let runway: RunwayTable
  var isLongest: Bool = false
  var isOptimal: Bool = false
}

struct AirportRunwayView: View {
  let runways: [RunwayTable]
  
  var body: some View {
    HStack {
      ForEach(runways, id: \.id) { rwy in
        RunwayView(rwy: rwy)
      }
    }
  }
}

struct RunwayView: View {
  let rwy: RunwayTable
  @State private var popoverVisible: Bool = false
  
  var body: some View {
    VStack {
      Text(rwy.runwayIdentifier)
        .fontWeight(.semibold)
      
      Button {
        popoverVisible = !popoverVisible
      } label: {
        ZStack {
          // Runway Surface
          RoundedRectangle(cornerRadius: 4)
            .fill(getRunwaySurface(surfaceCode: rwy.surfaceCode))
            .frame(width: 50, height: 180)
          
          // Runway Dashes
          VStack {
            ForEach(1...10, id: \.self) { dash in
              Rectangle()
                .frame(width: 3, height: 10)
                .foregroundStyle(.white)
            }
          }
          
          Text("\(rwy.runwayLength ?? 0)'")
            .foregroundStyle(.primary)
            .fontWeight(.semibold)
            .rotationEffect(.degrees(isInDegreeRange(bearing: rwy.runwayMagneticBearing) ? -90 : 90))
            .offset(x: isInDegreeRange(bearing: rwy.runwayMagneticBearing) ? 40 : -40)
            .foregroundStyle(.secondary)
          
          // Runway Identifier
          VStack {
            Spacer()
            Text("\(rwy.runwayIdentifier.split(separator: "RW")[0])")
              .foregroundStyle(.white)
              .background(getRunwaySurface(surfaceCode: rwy.surfaceCode))
              .font(.title3)
              .fontWeight(.semibold)
              .padding(.bottom, 12)
          }
        }
        .frame(width: 200, height: 200)
        .rotationEffect(.degrees(rwy.runwayMagneticBearing ?? 0))
        .glassEffect(.regular.tint(.vfr.opacity(0.4)), in: .rect(cornerRadius: 32, style: .continuous))
      }
      .buttonStyle(.plain)
    }
    .popover(isPresented: $popoverVisible) {
      RunwayPopoverView(rwy: rwy)
      .padding()
    }
  }
  
  func getRunwaySurface(surfaceCode: Int?) -> Color {
    guard let surfaceCode else { return .asphalt }
    switch surfaceCode {
    case 0:
      return .grass
    default:
      return .asphalt
    }
  }
  
  func isInDegreeRange(bearing: Double?) -> Bool {
    guard let bearing else { return true }
    return (0...180).contains(bearing)
  }
  
}

struct RunwayPopoverView: View {
  let rwy: RunwayTable
  
  var body: some View {
    Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 12) {
      GridRow {
        Text("Threshold Elev.")
          .fontWeight(.semibold)
        Text("\(rwy.landingThresholdElevation ?? 0)")
      }
      GridRow {
        Text("Width")
          .fontWeight(.semibold)
        Text("\(rwy.runwayWidth ?? 0)")
      }
      GridRow {
        Text("Mag. Bearing")
          .fontWeight(.semibold)
        Text(formatted(for: rwy.runwayMagneticBearing ?? 0))
      }
      GridRow {
        Text("True Bearing")
          .fontWeight(.semibold)
        Text(formatted(for: rwy.runwayTrueBearing ?? 0))
      }
      GridRow {
        Text("Gradient")
          .fontWeight(.semibold)
        Text(formatted(for: rwy.runwayGradient ?? 0))
      }
    }
  }
  
  func formatted(for value: Double) -> String {
    let val = value.formatted(.number.precision(.fractionLength(2)))
    return val
  }
}

#Preview {
  AirportRunwayView(runways: RunwayTable.mockKDSM)
}
