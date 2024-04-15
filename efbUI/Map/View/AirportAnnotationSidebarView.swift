//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation
import Neumorphic

// TODO: Separate this from AirportDetailViewModel
//  Reason: Will allow user to select multiple airports on map without affecting selected airport in AirportScreen
//  When user taps button in SidebarView to navigate to Airport Screen, change AirportDetailViewModel to selected airport (selectedAirportICAO property)
//  At same time, when AirportDetailViewModel.selectedAirportICAO is changed, it will not be necessary to call all fetch() functions
//    - Simply just update properties from SidebarView

struct AirportAnnotationSidebarView: View {
  @Binding var selectedTab: Int
  @Binding var selectedAirport: AirportTable?
  
  @Environment(AirportScreenViewModel.self) private var airportVM
  @State private var vm = AirportDetails()
  
  var body: some View {
    if let selectedAirport {
      VStack(spacing: 20) {
        /// Header
        HStack {
          Spacer()
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(!selectedAirport.airportIdentifier.isEmpty ? selectedAirport.airportIdentifier : selectedAirport.id)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .center)
          
          // TODO: Functions to refresh METAR, TAF, ATIS
          Button {
            print("refresh")
          } label: {
            Text("Refresh")
              .font(.system(size: 12))
          }
          .softButtonStyle(Capsule(), padding: 5)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(.trailing, 10)
        }
        
        List {
          Section {
            Grid(alignment: .leading) {
              GridRow {
                Text("CTAF")
                  .font(.subheadline)
                Text(vm.getCommunicationType(comms: vm.comms, type: "UNI"))
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
                  vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: true)
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
            .onAppear {
              vm.fetchFaaMetar(icao: selectedAirport.airportIdentifier)
            }
            .onChange(of: vm.wxSource.rawValue) {
              vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: false)
            }
            .onChange(of: vm.wxType.rawValue) {
              vm.fetchWx(for: vm.wxSource, type: vm.wxType, icao: selectedAirport.airportIdentifier, refresh: false)
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
                  Text("CTAF")
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
            selectedTab = 0
          } label: {
            Text("View Airport")
              .font(.system(size: 12))
          }
          .softButtonStyle(Capsule(), padding: 5)
          .frame(maxWidth: .infinity, alignment: .center)
          
          Spacer()
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
      }
      .onAppear {
        vm.fetchAirportDetails(icao: selectedAirport.airportIdentifier)
      }
    } else {
      ContentUnavailableView("Airport Details Unavailable", systemImage: "airplane.circle", description: Text("Select an airport on the map to view details."))
    }
  }
  
  func getWeather(_ source: WxSources, _ type: WxTabs) -> String {
    return "hello"
  }
}

