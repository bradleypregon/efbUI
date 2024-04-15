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
  @Environment(AirportScreenViewModel.self) private var airportDetailViewModel
  @Environment(SimBriefViewModel.self) private var sbViewModel
  
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [AirportDetail] = []
  @State private var selectedChartURL: String = ""
  
  @State private var rotation: Angle = .zero
  @GestureState private var twistAngle: Angle = .zero
  @State private var zoom: CGFloat = 1
  @GestureState private var pinchZoom: CGFloat = 1
  
//  @State private var canvas = PKCanvasView()
  
  @State private var selectedCharts: AirportChart = .Curr
  
  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      Picker("Airport", selection: $selectedCharts) {
        ForEach(AirportChart.allCases) { airport in
          if airport.rawValue == AirportChart.Star.rawValue {
            Image(systemName: "star.fill")
              .resizable()
          } else {
            Text(airport.rawValue)
          }
        }
      }
      .pickerStyle(.segmented)
      
      chartViewBuilder()
      
    } detail: {
      if let url = URL(string: selectedChartURL) {
        ZStack {
          PDFKitView(url: url)
//          DrawingView(canvas: $canvas)
        }
        .scaleEffect(zoom * pinchZoom)
        .rotationEffect(rotation + twistAngle)
        .gesture(RotationGesture()
          .updating($twistAngle, body: { value, state, _ in
            state = value
          })
          .onEnded { self.rotation += $0 }
          .simultaneously(with: MagnificationGesture()
            .updating($pinchZoom, body: { value, state, _ in
              state = value
            })
            .onEnded { self.zoom *= $0 }
          )
        )
      }
    }
  }
  
  @MainActor 
  @ViewBuilder
  func chartViewBuilder() -> some View {
    switch selectedCharts {
    case .Star:
      starredCharts()
    case .Curr:
      charts(charts: airportDetailViewModel.selectedAirportCharts)
    case .Orig:
      charts(charts: sbViewModel.depCharts)
    case .Dest:
      charts(charts: sbViewModel.arrCharts)
    case .Altn:
      charts(charts: sbViewModel.altnCharts)
    case .OFP:
      ofp()
    }
  }
  
  @MainActor 
  func starredCharts() -> some View {
    List {
      ForEach(starred, id: \.id) { chart in
        // TODO: swipe to remove chart
        HStack {
          Button {
            starred.removeAll { $0.id == chart.id }
          } label: {
            Image(systemName: "star.fill")
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
          Button {
            DispatchQueue.main.async {
              selectedChartURL = chart.pdfPath
            }
          } label: {
            Text(chart.chartName)
          }
          .buttonStyle(BorderedButtonStyle())
        }
      }
    }
  }
  
  @MainActor 
  func charts(charts: DecodedArray<AirportChartAPISchema>?) -> some View {
    List {
      if let charts = charts?.first {
        DisclosureGroup("General") {
          ForEach(charts.general, id: \.id) { chart in
            HStack {
              Button {
                if starred.contains(chart) {
                  starred.removeAll { $0.id == chart.id }
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
                  selectedChartURL = chart.pdfPath
                }
              } label: {
                Text(chart.chartName)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
        DisclosureGroup("Departure") {
          ForEach(charts.dp, id: \.id) { chart in
            HStack {
              Button {
                // TODO: Clicking chart keeps adding it to starred
                if starred.contains(chart) {
                  starred.removeAll { $0.id == chart.id }
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
                  selectedChartURL = chart.pdfPath
                }
              } label: {
                Text(chart.chartName)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
        DisclosureGroup("Arrival") {
          ForEach(charts.star, id: \.id) { chart in
            HStack {
              Button {
                // TODO: Clicking chart keeps adding it to starred
                if starred.contains(chart) {
                  starred.removeAll { $0.id == chart.id }
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
                  selectedChartURL = chart.pdfPath
                }
              } label: {
                Text(chart.chartName)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
        DisclosureGroup("Approach") {
          ForEach(charts.capp, id: \.id) { chart in
            HStack {
              Button {
                // TODO: Clicking chart keeps adding it to starred
                if starred.contains(chart) {
                  starred.removeAll { $0.id == chart.id }
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
                  selectedChartURL = chart.pdfPath
                }
              } label: {
                Text(chart.chartName)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
      }
    }
    .listStyle(.sidebar)
  }
  
  @MainActor
  func ofp() -> some View {
    List {
      if let ofp = sbViewModel.ofp {
        Button {
          selectedChartURL = "\(ofp.files.directory)\(ofp.files.pdf.link)"
        } label: {
          Text("OFP")
        }
        .buttonStyle(.bordered)
      }
    }
  }
  
  private enum AirportChart: String, CaseIterable, Identifiable {
    case Star, Curr, Orig, Dest, Altn, OFP
    var id: Self { self }
  }
}

#Preview {
  ChartsView(selectedTab: .constant(1))
}
