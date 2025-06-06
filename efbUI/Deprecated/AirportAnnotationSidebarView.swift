//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation

// TODO: Separate this from AirportDetailViewModel
//  Reason: Will allow user to select multiple airports on map without affecting selected airport in AirportScreen
//  When user taps button in SidebarView to navigate to Airport Screen, change AirportDetailViewModel to selected airport (selectedAirportICAO property)
//  At same time, when AirportDetailViewModel.selectedAirportICAO is changed, it will not be necessary to call all fetch() functions
//    - Simply just update properties from SidebarView

/*
struct AirportAnnotationSidebarView: View {
  @Binding var columnVisibility: NavigationSplitViewVisibility
  @Binding var selectedTab: efbTab
  var selectedAirport: AirportTable
  
  @Environment(AirportScreenViewModel.self) private var airportVM
  @State private var vm = AirportDetails()
  
  var body: some View {
    VStack(spacing: 20) {
      /// Header
      HStack {
        Text(!selectedAirport.airportIdentifier.isEmpty ? selectedAirport.airportIdentifier : selectedAirport.id)
          .frame(alignment: .leading)
        Divider()
        Text(selectedAirport.airportName)
      }
      .fontWeight(.semibold)
      .frame(height: 25)
      
      List {
        Section {
          Grid(alignment: .leading) {
            GridRow {
              Text("TWR")
                .font(.subheadline)
              Text(vm.getCommunicationType(comms: vm.comms, type: "TWR"))
                .fontWeight(.semibold)
            }
            GridRow {
              Text("ATIS")
                .font(.subheadline)
              Text(vm.getCommunicationType(comms: vm.comms, type: "ATI"))
                .fontWeight(.semibold)
            }
            GridRow {
              Text("Elev")
                .font(.subheadline)
              Text("\(selectedAirport.elevation)'")
                .fontWeight(.semibold)
            }
          }
        } header: {
          Text("Info")
            .fontWeight(.semibold)
            .font(.title3)
        }
        
        // TODO: Button to refresh Wx
        // Label to show how old weather is?
        Section {
          VStack {
            HStack {
              Text(vm.wxCategory.rawValue)
                .fontWeight(.semibold)
                .foregroundStyle(vm.wxCategoryColor(for: vm.wxCategory))
              Button {
                Task {
                  await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: true)
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
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: false)
            }
            
          }
          .onChange(of: vm.wxType.rawValue) {
            Task {
              await vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: false)
            }
          }
        } header: {
          Text("Wx")
            .fontWeight(.semibold)
            .font(.title3)
        }
        
        // TODO: Runway view like Airport Screen, but small?
        Section {
          VStack {
            ForEach(vm.runways, id: \.self) { runway in
              Text(runway.runwayIdentifier)
            }
          }
        } header: {
          Text("Rwy")
            .fontWeight(.semibold)
            .font(.title3)
        }
        
        Section {
          VStack {
            Grid(alignment: .leading) {
              GridRow {
                Text("ATIS")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "ATI"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Clearance")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "CLD"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Ground")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "GND"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Tower")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "TWR"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("UNI")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "UNI"))
                  .fontWeight(.semibold)
              }
            }
          }
        } header: {
          Text("Freqs")
            .fontWeight(.semibold)
            .font(.title3)
        }
      }
      .listStyle(.insetGrouped)
      
      Spacer()
      HStack {
        VStack {
          Text("\(String(format: "%.4f", selectedAirport.airportRefLat))")
          Text("\(String(format: "%.4f", selectedAirport.airportRefLong))")
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.gray)
        
        // TODO: Make button bigger
        Button {
          airportVM.selectedAirportICAO = selectedAirport.airportIdentifier
          selectedTab = .airports
        } label: {
          Text("View Airport")
            .font(.system(size: 12))
        }
        .buttonStyle(.borderedProminent)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
      }
      
    }
    .task {
      if selectedAirport.airportIdentifier != vm.prevICAO {
        await vm.fetchFaaMetar(icao: selectedAirport.airportIdentifier)
      }
      await vm.fetchAirportDetails(icao: selectedAirport.airportIdentifier)
    }
    .onDisappear {
      vm.wxSource = .faa
      vm.wxType = .metar
    }
  }
}

*/
