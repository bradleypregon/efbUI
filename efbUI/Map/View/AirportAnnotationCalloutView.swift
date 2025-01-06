//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation

struct AirportAnnotationCalloutView: View {
  @Environment(AirportScreenViewModel.self) private var airportVM
  
  @Binding var selectedTab: efbTab
  var airport: AirportTable
  @State private var vm = AirportDetails()
  
  var body: some View {
    VStack {
      // Header
      HStack {
        Text(!airport.airportIdentifier.isEmpty ? airport.airportIdentifier : airport.id)
        Divider()
        Text(airport.airportName)
          .frame(width: .infinity)
      }
      .fontWeight(.semibold)
      .multilineTextAlignment(.center)

      Divider()
      
      List {
        Section {
          Grid {
            GridRow {
              Text("TWR")
                .font(.subheadline)
              Text(vm.getCommunicationType(comms: vm.comms, type: "TWR"))
                .fontWeight(.semibold)
            }
            GridRow {
              // get ATIS otherwise get AWOS or ASOS
              Text("\(vm.getATIS(comms: vm.comms).first?.communicationType ?? "Wx Type N/A")")
                .font(.subheadline)
              Text("\(vm.getATIS(comms: vm.comms).first?.communicationFrequency ?? .zero)")
                .fontWeight(.semibold)
            }
            GridRow {
              Text("Elev")
                .font(.subheadline)
              Text("\(airport.elevation)'")
                .fontWeight(.semibold)
            }
          }
        } header: {
          Text("Info")
        }
        
        Section {
          VStack {
            HStack {
              Text(vm.wxCategory.rawValue)
                .fontWeight(.semibold)
                .foregroundStyle(vm.wxCategoryColor(for: vm.wxCategory))
              Button {
                Task {
                  await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: true)
                }
              } label: {
                Text("Refresh")
              }
              .clipShape(Capsule())
            }
            
            Divider()
            
            Picker("Weather Source", selection: $vm.wxSource) {
              ForEach(WxSources.allCases) { source in
                Text(source.rawValue.uppercased())
              }
            }
            .pickerStyle(.segmented)
            
            Picker("Weather Type", selection: $vm.wxType) {
              ForEach(WxTabs.allCases) { tab in
                Text(tab.rawValue)
              }
            }
            .pickerStyle(.segmented)
            
            Text(vm.currentWxString)
              .font(.system(size: 14))
          }
          .onChange(of: vm.wxSource.rawValue) {
            Task {
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: false)
            }
            
          }
          .onChange(of: vm.wxType.rawValue) {
            Task {
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: airport.airportIdentifier, refresh: false)
            }
          }
        } header: {
          Text("Weather")
        }
        
        Section {
          VStack {
            ForEach(vm.runways, id: \.self) { runway in
              Text(runway.runwayIdentifier)
            }
          }
        } header: {
          Text("Runways")
        }
      }
      .listStyle(.insetGrouped)
      
      HStack {
        VStack {
          Text("\(String(format: "%.4f", airport.airportRefLat))")
          Text("\(String(format: "%.4f", airport.airportRefLong))")
        }
        .font(.caption2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.gray)
        
        Button {
          airportVM.selectedAirportICAO = airport.airportIdentifier
          selectedTab = .airports
        } label: {
          Text("View Airport")
            .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        
      }
      
    }
    .padding()
    .task {
      if airport.airportIdentifier != vm.prevICAO {
        await vm.fetchFaaMetar(icao: airport.airportIdentifier)
      }
      await vm.fetchAirportDetails(icao: airport.airportIdentifier)
    }
    .onDisappear {
      
    }
  }
}
