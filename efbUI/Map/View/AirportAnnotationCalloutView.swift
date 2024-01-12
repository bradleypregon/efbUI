//
//  AirportMapCalloutView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import SwiftUI
import CoreLocation
import Neumorphic

enum AirportAnnotationCalloutInfoTab: String, Identifiable, CaseIterable {
  // general info, weather, runways, frequencies
  // general info: atis freq, shorthand runways, city served
  case info, wx, freq
  var id: Self { self }
}

struct AirportAnnotationCalloutView: View {
  @Binding var selectedTab: Int
  @Binding var selectedAirport: AirportTable?
  
  @State private var airportVM = AirportDetailViewModel.shared
  @State var selectedInfoTab: AirportAnnotationCalloutInfoTab = .info
  
  var body: some View {
    if let airport = selectedAirport {
      VStack {
        // Header
        HStack {
          Spacer()
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(!airport.airportIdentifier.isEmpty ? airport.airportIdentifier : airport.id)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .center)
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
        
        // Airport Name
        Text(airport.airportName)
          .multilineTextAlignment(.center)
          .font(.caption)
          .foregroundStyle(.gray)
        Divider()
        Picker(selection: $selectedInfoTab, label: Text("Picker")) {
          ForEach(AirportAnnotationCalloutInfoTab.allCases) { tab in
            Text(tab.rawValue.capitalized)
          }
        }
        .pickerStyle(.segmented)
        AirportAnnotationCalloutInfoTabBuilder(selectedTab: selectedInfoTab, airportAnnotation: airport)
        
        Spacer()
        HStack {
          VStack {
            Text("\(String(format: "%.4f", airport.airportRefLat))")
            Text("\(String(format: "%.4f", airport.airportRefLong))")
          }
          .font(.caption2)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundStyle(.gray)
          
          Button {
            AirportDetailViewModel.shared.selectedAirportICAO = "KDSM"
            selectedTab = 0
          } label: {
            Text("View Airport")
              .font(.system(size: 12))
          }
          .softButtonStyle(Capsule(), padding: 5)
          .frame(maxWidth: .infinity, alignment: .center)
          
        }
        
      }
      .padding(1)
      .onAppear {
        // TODO: Get data if airport is major, otherwise, click button to get data
        //      airportDBAPI.fetchAirportDBInfo(icao: locationData.icao) { data in
        //        self.data = data
        //      }
        
      }
  //    .frame(width: 250, height: 300)
      .backgroundStyle(Color.Neumorphic.main)
    }
    
  }
}

struct AirportAnnotationCalloutInfoTabBuilder: View {
  let selectedTab: AirportAnnotationCalloutInfoTab
  let airportAnnotation: AirportTable
  
  @ViewBuilder
  var body: some View {
    switch selectedTab {
    case .info:
      InfoTab(airportAnnotation: airportAnnotation)
    case .wx:
      WxTab(airportAnnotation: airportAnnotation)
    case .freq:
      FreqTab(airportAnnotation: airportAnnotation)
    }
  }
}

struct InfoTab: View {
  let airportAnnotation: AirportTable
  // shorthand runways, size, atis, elevation
  var body: some View {
    HStack {
      Spacer()
        .frame(width: 5)
      
      // Grid of cards
      
      // Runways
      VStack {
        Text("Runways")
          .foregroundStyle(.gray)
        ScrollView(.vertical) {
          // runways
//          ForEach(airportAnnotation.properties.runways, id: \.self) { runway in
//            InfoTabRunwayCard(runway: runway)
//            Divider()
//          }
        }
        .frame(width: 75, height: .infinity)
      }
      
      Divider()
      
      // size
      VStack {
        HStack {
          Spacer()
            .frame(width: 10)
          Text("Size")
            .foregroundStyle(.gray)
          Spacer()
        }
        Grid {
          GridRow {
            Text("ILS cap?")
          }
        }
        .frame(width: 175, height: 25)
      }
      
    }
    .font(.system(size: 12))
    
  }
}

struct InfoTabRunwayCard: View {
  
  var body: some View {
    VStack {
      Text("runways")
      //      ZStack {
      //        Rectangle()
      //          .stroke(.white)
      //          .fill(Color(runway.surface))
      //        Text("\(runway.lengthFt)ft")
      //          .foregroundStyle(.black)
      //      }
      //      .frame(maxWidth: 75)
      //      .rotationEffect(.degrees(runwayHeading(runway.runway)-90.0), anchor: .center)
    }
  }
  
  func runwayHeading(_ runway: String) -> Double {
    // 09/27 -> 090
    if runway.isEmpty { return 0.0 }
    
    let rwy = runway.split(separator: "/")[0]
    let heading = rwy + "0"
    
    if let temp = Int(heading) {
      if temp > 180 {
        let temp2 = temp - 180
        return Double(temp2)
      }
    }
    return Double(Int(heading) ?? 0)
  }
}

struct WxTab: View {
  let airportAnnotation: AirportTable
  
  var body: some View {
    Text("Wx Tab")
  }
}

struct FreqTab: View {
  let airportAnnotation: AirportTable
  
  var body: some View {
    Text("Freq Tab")
  }
}

//#Preview {
//  MapCalloutView(rootView: AnyView(AirportAnnotationCalloutView(selectedTab: .constant(1), airport: TestAirportTable(areaCode: "USA", airportIdentifier: "KDSM", airportName: "Des Moines Intl", airportRefLat: 41.53388888, airportRefLong: -93.6630555555), filteredAirport: [])
//    .previewLayout(.sizeThatFits)))
//}
