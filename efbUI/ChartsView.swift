//
//  ChartsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/25/24.
//

import SwiftUI
import PencilKit

enum TestChartType: String, CaseIterable, Identifiable {
  case favorite, current, route, ofp
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
  
  @State private var selectedCharts: AirportChart = .Curr
  
  @State var searchText: String = ""
  @State var testPickerType: TestChartType = .current
  
  @State private var drawingTool: PKTool = PKInkingTool(.pen, color: .red, width: 10)
  @State private var drawing: PKDrawing = PKDrawing()
  
  //  @State private var tempCharts: [TempAirportChart] = []
  
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
        
//        Picker("Chart Type", selection: $testPickerType) {
//          ForEach(TestChartType.allCases) { type in
//            if type == .favorite {
//              Image(systemName: "star.fill")
//                .resizable()
//            } else {
//              Text(type.rawValue.capitalized)
//            }
//          }
//        }
//        .pickerStyle(.segmented)
        
        chartViewBuilder()
        //        .task {
        //          if let temp = sbViewModel.depCharts {
        //            tempCharts.append(TempAirportChart(stage: .dep, charts: temp))
        //          }
        //          if let temp = sbViewModel.arrCharts {
        //            tempCharts.append(TempAirportChart(stage: .arr, charts: temp))
        //          }
        //          if let temp = sbViewModel.altnCharts {
        //            tempCharts.append(TempAirportChart(stage: .altn, charts: temp))
        //          }
        //        }
      }
      
    } detail: {
      if let url = URL(string: selectedChartURL) {
        VStack {
          HStack {
            // PDF Controls
            Spacer()
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
            .layoutPriority(2)
            Spacer()
            // Canvas Toolbar
            CanvasToolbarView(
              selTool: $drawingTool,
              onClear: {
                drawing = PKDrawing()
              }
            )
            .layoutPriority(1)
          }
          .frame(alignment: .center)
          
          ZStack {
            PDFKitView(url: url)
            DrawingView(drawing: $drawing, tool: $drawingTool, pencilOnly: true)
          }
          .padding(.top, 30)
          .scaleEffect(zoom * pinchZoom)
          .rotationEffect(rotation)
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
      charts()
    case .Route:
      routeCharts()
    case .OFP:
      ofp()
    }
  }
  
  @MainActor
  func starredCharts() -> some View {
    // TODO: Sections with Current and Route charts
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
  func charts() -> some View {
    List {
      if let charts = airportDetailViewModel.selectedAirportCharts {
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
  }
  
  @MainActor
  func routeCharts() -> some View {
    List {
      // Origin
      Section {
        if let temp = sbViewModel.depCharts {
          chartGroup(name: "General", chart: temp.general)
          chartGroup(name: "Departure", chart: temp.dp)
          chartGroup(name: "Arrival", chart: temp.star)
          chartGroup(name: "Approach", chart: temp.capp)
        }
      } header: {
        Text("Origin (\(sbViewModel.ofp?.origin.icaoCode ?? ""))")
      }
      
      // Destination
      Section {
        if let temp = sbViewModel.arrCharts {
          chartGroup(name: "General", chart: temp.general)
          chartGroup(name: "Departure", chart: temp.dp)
          chartGroup(name: "Arrival", chart: temp.star)
          chartGroup(name: "Approach", chart: temp.capp)
        }
      } header: {
        Text("Destination (\(sbViewModel.ofp?.destination.icaoCode ?? ""))")
      }
      
      // Alternates
      // TODO: ForEach for sbViewModel.ofp?.alternates
      // need to fix sbViewModel.altnCharts to be actual array
      Section {
        if let temp = sbViewModel.altnCharts {
          chartGroup(name: "General", chart: temp.general)
          chartGroup(name: "Departure", chart: temp.dp)
          chartGroup(name: "Arrival", chart: temp.star)
          chartGroup(name: "Approach", chart: temp.capp)
        }
      } header: {
        Text("Alternates")
      }
    }
  }
  
  @MainActor
  func currentCharts(charts: AirportChartAPISchema?) -> some View {
    List {
      if let chart = charts {
        chartGroup(name: "General", chart: chart.general)
        chartGroup(name: "Departure", chart: chart.dp)
        chartGroup(name: "Arrival", chart: chart.star)
        chartGroup(name: "Approach", chart: chart.capp)
      }
    }
    .listStyle(.insetGrouped)
  }
  
  @MainActor
  func chartGroup(name: String, chart: [Chart]) -> some View {
    DisclosureGroup(name) {
      ForEach(chart, id: \.id) { chart in
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
}

private enum AirportChart: String, CaseIterable, Identifiable {
  case Star, Curr, Route, OFP
  var id: Self { self }
}

#Preview {
  ChartsView(selectedTab: .constant(.charts))
}
