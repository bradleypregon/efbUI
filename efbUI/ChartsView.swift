//
//  ChartsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/25/24.
//

import SwiftUI
import PencilKit

struct ChartsView: View {
  @Environment(AppCoordinator.self) private var coordinator
  @Environment(SimBriefViewModel.self) private var sbViewModel
  
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [ChartAPIChartSchema] = []
  @State private var selectedChartURL: String = ""
  
  @State private var rotation: Angle = .zero
  @GestureState private var twistAngle: Angle = .zero
  @State private var zoom: CGFloat = 1
  @GestureState private var pinchZoom: CGFloat = 1
  
  @State private var selectedTab: ChartTab = .Route
  
  @State var searchText: String = ""
  
  @State private var drawingTool: PKTool = PKInkingTool(.pen, color: .red, width: 10)
  @State private var drawing: PKDrawing = PKDrawing()
  
  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      VStack {
        TextField("Search (INOP)", text: $searchText)
          .textFieldStyle(.roundedBorder)
          .padding([.leading, .trailing])
        
        Picker("Airport", selection: $selectedTab) {
          ForEach(ChartTab.allCases) { airport in
            if airport.rawValue == ChartTab.Star.rawValue {
              Image(systemName: "star.fill")
                .resizable()
            } else {
              Text(airport.rawValue)
            }
          }
        }
        .pickerStyle(.segmented)
        
        chartViewBuilder()
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
    switch selectedTab {
    case .Star:
      starredCharts()
//    case .Curr:
//      charts()
    case .Route:
      routeCharts()
    }
  }
  
  @MainActor
  func starredCharts() -> some View {
    // TODO: Sections with Current and Route charts
    List {
      ForEach(starred) { chart in
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
              selectedChartURL = chart.pdfURL
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
  
//  @MainActor
//  func charts() -> some View {
//    List {
//      if let charts = coordinator.charts?.charts {
//        DisclosureGroup("General") {
//          ForEach(charts.general) { chart in
//            HStack {
//              Button {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  starred.removeAll { $0.id == chart.id }
//                } else {
//                  starred.append(chart)
//                }
//              } label: {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  Image(systemName: "star.fill")
//                } else {
//                  Image(systemName: "star")
//                }
//              }
//              .buttonStyle(PlainButtonStyle())
//              Spacer()
//              Button {
//                selectedChartURL = chart.pdfURL
//              } label: {
//                Text(chart.chartName)
//              }
//              .buttonStyle(BorderedButtonStyle())
//            }
//          }
//        }
//        DisclosureGroup("Departure") {
//          ForEach(charts.departure) { chart in
//            HStack {
//              Button {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  starred.removeAll { $0.id == chart.id }
//                } else {
//                  starred.append(chart)
//                }
//              } label: {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  Image(systemName: "star.fill")
//                } else {
//                  Image(systemName: "star")
//                }
//              }
//              .buttonStyle(PlainButtonStyle())
//              Spacer()
//              Button {
//                selectedChartURL = chart.pdfURL
//              } label: {
//                Text(chart.chartName)
//              }
//              .buttonStyle(BorderedButtonStyle())
//            }
//          }
//        }
//        DisclosureGroup("Arrival") {
//          ForEach(charts.arrival) { chart in
//            HStack {
//              Button {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  starred.removeAll { $0.id == chart.id }
//                } else {
//                  starred.append(chart)
//                }
//              } label: {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  Image(systemName: "star.fill")
//                } else {
//                  Image(systemName: "star")
//                }
//              }
//              .buttonStyle(PlainButtonStyle())
//              Spacer()
//              Button {
//                selectedChartURL = chart.pdfURL
//              } label: {
//                Text(chart.chartName)
//              }
//              .buttonStyle(BorderedButtonStyle())
//            }
//          }
//        }
//        DisclosureGroup("Approach") {
//          ForEach(charts.approach) { chart in
//            HStack {
//              Button {
//                if starred.contains(where: { $0.id == chart.id }) {
//                  starred.removeAll { $0.id == chart.id }
//                } else {
//                  starred.append(chart)
//                }
//              } label: {
//                Image(systemName: starred.contains(where: { $0.id == chart.id }) ? "star.fill" : "star")
//              }
//              .buttonStyle(PlainButtonStyle())
//              Spacer()
//              Button {
//                selectedChartURL = chart.pdfURL
//              } label: {
//                Text(chart.chartName)
//              }
//              .buttonStyle(BorderedButtonStyle())
//            }
//          }
//        }
//      }
//    }
//  }
  
  @MainActor
  func routeCharts() -> some View {
    List {
      // Origin
      Section {
        if let temp = sbViewModel.depCharts {
          chartGroup(name: "General", chart: temp.charts.general)
          chartGroup(name: "Departure", chart: temp.charts.departure)
          chartGroup(name: "Arrival", chart: temp.charts.arrival)
          chartGroup(name: "Approach", chart: temp.charts.approach)
        }
      } header: {
        Text("Origin (\(sbViewModel.ofp?.origin.icaoCode ?? ""))")
      }
      
      // Destination
      Section {
        if let temp = sbViewModel.arrCharts {
          chartGroup(name: "General", chart: temp.charts.general)
          chartGroup(name: "Departure", chart: temp.charts.departure)
          chartGroup(name: "Arrival", chart: temp.charts.arrival)
          chartGroup(name: "Approach", chart: temp.charts.approach)
        }
      } header: {
        Text("Destination (\(sbViewModel.ofp?.destination.icaoCode ?? ""))")
      }
      
      // Alternates
      // TODO: ForEach for sbViewModel.ofp?.alternates
      // need to fix sbViewModel.altnCharts to be actual array
      Section {
        if let temp = sbViewModel.altnCharts {
          chartGroup(name: "General", chart: temp.charts.general)
          chartGroup(name: "Departure", chart: temp.charts.departure)
          chartGroup(name: "Arrival", chart: temp.charts.arrival)
          chartGroup(name: "Approach", chart: temp.charts.approach)
        }
      } header: {
        Text("Alternates")
      }
    }
  }
  
  @MainActor
  func currentCharts(charts: ChartAPISchema?) -> some View {
    List {
      if let chart = charts?.charts {
        chartGroup(name: "General", chart: chart.general)
        chartGroup(name: "Departure", chart: chart.departure)
        chartGroup(name: "Arrival", chart: chart.arrival)
        chartGroup(name: "Approach", chart: chart.approach)
      }
    }
    .listStyle(.insetGrouped)
  }
  
  @MainActor
  func chartGroup(name: String, chart: [ChartAPIChartSchema]) -> some View {
    DisclosureGroup(name) {
      ForEach(chart) { chart in
        HStack {
          Button {
            if starred.contains(where: { $0.id == chart.id }) {
              starred.removeAll { $0.id == chart.id }
            } else {
              starred.append(chart)
            }
          } label: {
            if starred.contains(where: { $0.id == chart.id }) {
              Image(systemName: "star.fill")
            } else {
              Image(systemName: "star")
            }
          }
          .buttonStyle(PlainButtonStyle())
          Spacer()
          Button {
            selectedChartURL = chart.pdfURL
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

private enum ChartTab: String, CaseIterable, Identifiable {
//  case Star, Curr, Route
  case Star, Route
  var id: Self { self }
}

#Preview {
  ChartsView()
}
