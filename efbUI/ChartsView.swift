//
//  ChartsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/25/24.
//

import SwiftUI
import PencilKit

struct ChartsView: View {
  @Binding var selectedTab: Int
  @Environment(AirportDetailViewModel.self) private var airportDetailViewModel
  //  let charts: DecodedArray<AirportChartAPISchema>? = nil
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [AirportDetail] = []
  @State private var selectedChart: AirportDetail?
  
  @State private var rotation: Angle = Angle.zero
  @GestureState private var twistAngle: Angle = Angle.zero
  @State private var zoom: CGFloat = 0.75
  @GestureState private var pinchZoom: CGFloat = 1
  
  @State private var canvas = PKCanvasView()
  
  var body: some View {
    if let charts = airportDetailViewModel.selectedAirportCharts?.first {
      NavigationSplitView(columnVisibility: $columnVisibility) {
        // sidebar
        List {
          /// Starred Charts
          DisclosureGroup("Starred") {
            ForEach(starred, id: \.chartName) { chart in
              // TODO: swipe to remove chart
              HStack {
                Button {
                  starred.removeAll { $0.chartName == chart.chartName }
                } label: {
                  Image(systemName: "star.fill")
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button {
                  DispatchQueue.main.async {
                    selectedChart = chart
                  }
                } label: {
                  Text(chart.chartName)
                }
                .buttonStyle(BorderedButtonStyle())
              }
            }
          }
          
          // TODO: Change to foreach loop to eliminate each disclosure group?
          /// General Charts
          DisclosureGroup("General") {
            ForEach(charts.general, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button {
                  DispatchQueue.main.async {
                    selectedChart = chart
                  }
                } label: {
                  Text(chart.chartName)
                }
                .buttonStyle(BorderedButtonStyle())
              }
            }
          }
          
          /// Departure Charts
          DisclosureGroup("Departure") {
            ForEach(charts.dp, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button {
                  DispatchQueue.main.async {
                    selectedChart = chart
                  }
                } label: {
                  Text(chart.chartName)
                }
                .buttonStyle(BorderedButtonStyle())
              }
            }
          }
          
          /// Arrival Charts
          DisclosureGroup("Arrival") {
            ForEach(charts.star, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button {
                  DispatchQueue.main.async {
                    selectedChart = chart
                  }
                } label: {
                  Text(chart.chartName)
                }
                .buttonStyle(BorderedButtonStyle())
              }
            }
          }
          
          /// Approach Charts
          DisclosureGroup("Approach") {
            ForEach(charts.capp, id: \.chartName) { chart in
              HStack {
                Button {
                  // TODO: Clicking chart keeps adding it to starred
                  if starred.contains(chart) {
                    starred.removeAll { $0.chartName == chart.chartName }
                  } else {
                    starred.append(chart)
                  }
                } label: {
                  if starred.contains(chart) {
                    Image(systemName: "star.fill")
                  } else {
                    Image(systemName: "star")
                  }
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button {
                  DispatchQueue.main.async {
                    selectedChart = chart
                  }
                } label: {
                  Text(chart.chartName)
                }
                .buttonStyle(BorderedButtonStyle())
              }
            }
          }
        }
        .listStyle(.sidebar)
      } detail: {
        // detail
        // chart viewer
        if let pdfPath = selectedChart?.pdfPath, let url = URL(string: pdfPath) {
          
          ZStack {
            PDFKitView(url: url)
            DrawingView(canvas: $canvas)
          }
          .scaleEffect(zoom * pinchZoom)
          .rotationEffect(rotation + twistAngle)
          .gesture(RotationGesture()
            .updating($twistAngle, body: { value, state, _ in
              state = value
            })
//            .onEnded { self.rotation += $0 }
            .onEnded({ value in
              let nearestAngle = self.calculateNearestCardinalAngle(angle: value.degrees)
              withAnimation {
                self.rotation += .degrees(nearestAngle)
              }
            })
            .simultaneously(with: MagnificationGesture()
              .updating($pinchZoom, body: { value, state, _ in
                state = value
              })
              .onEnded { self.zoom *= $0 }
            )
          )
          //          .gesture(MagnificationGesture()
          //            .updating($pinchZoom, body: { value, state, _ in
          //              state = value
          //            })
          //              .onEnded({ value in
          //                self.zoom *= value
          //              })
          //          )
        } else {
          Text("PDF will show up here")
        }
      }
    } else {
      Color.clear
    }
  }
  
  private func calculateNearestCardinalAngle(angle: Double) -> Double {
    let cardinalAngles: [Double] = [0, 90, 180, 270, 360]
    let nearestAngle = cardinalAngles.min { abs($0 - angle) < abs($1 - angle) } ?? 0
    return nearestAngle
  }
}

#Preview {
  ChartsView(selectedTab: .constant(1))
}
