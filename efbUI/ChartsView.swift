//
//  ChartsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/25/24.
//

import SwiftUI
import PencilKit

enum TestChartType: String, CaseIterable, Identifiable {
  case favorite, current, route
  var id: Self { self }
}

struct ChartsView: View {
  @Binding var selectedTab: efbTab
  @Environment(AirportScreenViewModel.self) private var airportDetailViewModel
  @Environment(SimBriefViewModel.self) private var sbViewModel
  
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [Chart] = []
  @State private var selectedChartURL: String = ""
  
  @State private var rotation: Angle = .zero
  @GestureState private var twistAngle: Angle = .zero
  @State private var zoom: CGFloat = 1
  @GestureState private var pinchZoom: CGFloat = 1
  
  @State private var canvas = PKCanvasView()
  
  @State private var selectedCharts: AirportChart = .Curr
  @State private var drawingEnabled: Bool = false
  
  @State var searchText: String = ""
  @State var testPickerType: TestChartType = .current
  
  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      VStack {
        TextField("Search (INOP)", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .padding([.leading, .trailing])
        
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
        
        Picker("Type", selection: $testPickerType) {
          ForEach(TestChartType.allCases) { type in
            if type == TestChartType.favorite {
              Image(systemName: "star.fill")
                .resizable()
            } else {
              Text(type.rawValue.capitalized)
            }
          }
        }
        .pickerStyle(.segmented)
        
        chartViewBuilder()
      }
      
    } detail: {
      if let url = URL(string: selectedChartURL) {
        ZStack {
          ZStack {
            PDFKitView(url: url)
            if drawingEnabled {
              DrawingView(canvas: $canvas)
            }
          }
          .scaleEffect(zoom * pinchZoom)
          .rotationEffect(rotation)
          
          VStack {
            Spacer()
            HStack(spacing: 15) {
              Button {
                rotation -= .degrees(90)
              } label: {
                Image(systemName: "arrowshape.turn.up.left.fill")
                  .font(.title)
                  .foregroundStyle(.mvfr)
              }
              Button {
                rotation = .degrees(0)
              } label: {
                Image(systemName: "rectangle.portrait.fill")
                  .font(.title)
                  .foregroundStyle(.mvfr)
              }
              Button {
                rotation += .degrees(90)
              } label: {
                Image(systemName: "arrowshape.turn.up.right.fill")
                  .font(.title)
                  .foregroundStyle(.mvfr)
              }
            }
            Spacer()
              .frame(height: 20)
          }
        }
        .toolbar {
          Toggle("Drawing View", systemImage: drawingEnabled ? "pencil" : "pencil.slash", isOn: $drawingEnabled)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
        }
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
        .swipeActions(edge: .trailing) {
          Button(role: .destructive) {
            starred.removeAll { $0.id == chart.id }
          } label: {
            Label("Delete", systemImage: "trash")
          }
        }
      }
    }
  }
  
  @MainActor 
  func charts(charts: AirportChartAPISchema?) -> some View {
      List {
        if let charts = charts {
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
                selectedChartURL = chart.pdfPath
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
                selectedChartURL = chart.pdfPath
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
                selectedChartURL = chart.pdfPath
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
                if starred.contains(chart) {
                  starred.removeAll { $0.id == chart.id }
                } else {
                  starred.append(chart)
                }
              } label: {
                Image(systemName: starred.contains(chart) ? "star.fill" : "star")
              }
              .buttonStyle(PlainButtonStyle())
              Spacer()
              Button {
                selectedChartURL = chart.pdfPath
              } label: {
                Text(chart.chartName)
              }
              .buttonStyle(BorderedButtonStyle())
            }
          }
        }
     }
    }
      .listStyle(.insetGrouped)
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
  ChartsView(selectedTab: .constant(.charts))
}
