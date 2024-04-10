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
  @Environment(AirportDetailViewModel.self) private var airportVM
  
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
        
        Divider()
        List {
          // TODO: Add CTAF/UNI com frequency, drop other frequencies
          // add Elevation
          Section {
            Grid(alignment: .leading) {
              GridRow {
                Text("ATIS")
                  .font(.subheadline)
                Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "ATI"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Clearance")
                  .font(.subheadline)
                Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "CLD"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Ground")
                  .font(.subheadline)
                Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "GND"))
                  .fontWeight(.semibold)
              }
              GridRow {
                Text("Tower")
                  .font(.subheadline)
                Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "TWR"))
                  .fontWeight(.semibold)
              }
            }
          } header: {
            Text("Info")
          }
          
          Section {
            if airportVM.loadingAirportWx {
              ProgressView()
            } else {
              VStack {
                if let wx = airportVM.airportWxMetar {
                  Text(airportVM.calculateWxCategory(wx: wx).rawValue)
                }
                
                Text("METAR")
                Text(airportVM.airportWxMetar?.first?.rawOb ?? "METAR INOP")
                DisclosureGroup("TAF") {
                  if let tafs = airportVM.airportWxTAF {
                    ForEach(tafs, id: \.self) { taf in
                      Text(taf)
                    }
                  } else {
                    Text("TAF INOP")
                  }
                }
                
              }
            }
          } header: {
            Text("Wx")
          }
          
          Section {
            VStack {
              ForEach(airportVM.selectedAirportRunways ?? [], id: \.self) { runway in
                Text(runway.runwayIdentifier)
              }
            }
          } header: {
            Text("Rwy")
          }
          
          Section {
            VStack {
              Grid(alignment: .leading) {
                GridRow {
                  Text("ATIS")
                    .font(.subheadline)
                  Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "ATI"))
                    .fontWeight(.semibold)
                }
                GridRow {
                  Text("Clearance")
                    .font(.subheadline)
                  Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "CLD"))
                    .fontWeight(.semibold)
                }
                GridRow {
                  Text("Ground")
                    .font(.subheadline)
                  Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "GND"))
                    .fontWeight(.semibold)
                }
                GridRow {
                  Text("Tower")
                    .font(.subheadline)
                  Text(airportVM.getCommunicationType(comms: airportVM.selectedAirportComms, type: "TWR"))
                    .fontWeight(.semibold)
                }
              }
            }
          } header: {
            Text("Freqs")
          }
        }
        .listStyle(.plain)
        
        Spacer()
        HStack {
          VStack {
            Text("\(String(format: "%.4f", selectedAirport.airportRefLat))")
            Text("\(String(format: "%.4f", selectedAirport.airportRefLong))")
          }
          .font(.caption)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(.gray)
          
          Button {
            //            AirportDetailViewModel.shared.selectedAirportICAO = selectedAirport.airportIdentifier
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
      .padding(1)
      .onAppear {
        // TODO: Get data if airport is major, otherwise, click button to get data
        // query?
        airportVM.selectedAirportICAO = selectedAirport.airportIdentifier
      }
    } else {
      ContentUnavailableView("Airport Details Unavailable", systemImage: "airplane.circle", description: Text("Select an airport on the map to view details."))
    }
  }
}

