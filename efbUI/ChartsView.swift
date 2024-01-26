//
//  ChartsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/25/24.
//

import SwiftUI

struct ChartsView: View {
  @Binding var selectedTab: Int
  @Environment(AirportDetailViewModel.self) private var airportDetailViewModel
//  let charts: DecodedArray<AirportChartAPISchema>? = nil
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var starred: [AirportDetail] = []
  @State private var selectedChart: AirportDetail?
  
  var body: some View {
    if let charts = airportDetailViewModel.selectedAirportCharts?.first {
      NavigationSplitView(columnVisibility: $columnVisibility) {
        // sidebar
        List {
          /// Starred Charts
          DisclosureGroup("Starred") {
            ForEach(starred, id: \.chartName) { chart in
              // TODO: swipe to remove chart
              Text(chart.chartName)
            }
          }
          
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
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
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
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
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
                
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
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
                Spacer()
                Button {
                  selectedChart = chart
                } label: {
                  Text(chart.chartName)
                }
              }
            }
          }
        }
        .listStyle(.sidebar)
      } detail: {
        // detail
        // chart viewer
        if let pdfPath = selectedChart?.pdfPath, let url = URL(string: pdfPath) {
          PDFKitView(url: url)
        } else {
          Text("PDF will show up here")
        }
      }
    } else {
      Color.clear
    }
  }
}

#Preview {
  ChartsView(selectedTab: .constant(1))
}
