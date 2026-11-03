//
//  MapScreenWeatherPanel.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/30/26.
//

import SwiftUI

struct MapScreenWeatherPanel: View {
  @Binding var vm: MapViewModel
  @State var popoverVisible: Bool = false
  
  enum LayerID { case radar, metar, sigmet, icing, wxwss }
  
  struct MapWeatherLayer: Identifiable {
    let id: LayerID
    let name: String
    let icon: String
    var isOn: Bool = false
  }
  
  @State private var layers: [MapWeatherLayer] = [
    MapWeatherLayer(id: .radar,  name: "Radar",  icon: "dot.radiowaves.left.and.right"),
    MapWeatherLayer(id: .metar,  name: "METAR",  icon: "cloud.sun"),
    MapWeatherLayer(id: .sigmet, name: "SIGMET", icon: "hazardsign"),
    MapWeatherLayer(id: .icing,  name: "Icing",  icon: "snowflake"),
    MapWeatherLayer(id: .wxwss, name: "WxWSS", icon: "")
  ]
  
  @State private var radarVisible: Bool = false
  
  var body: some View {
    HStack {
      Button("Layers") { popoverVisible.toggle() }
      .buttonStyle(.glass)
      .popover(isPresented: $popoverVisible) {
        ForEach($layers) { $layer in
          Toggle(layer.name, systemImage: layer.icon, isOn: $layer.isOn)
            .glassEffect()
            .toggleStyle(.button)
            .font(.title3)
            .fontWeight(.semibold)
            .tint(layer.isOn ? .primary : .secondary)
            .task(id: layer.isOn) {
              await handleToggle(for: layer)
            }
        }
        .padding()
      }
      
      if radarVisible {
        Toggle("Composite", isOn: $vm.radarVM.compositeRadarVisible)
          .glassEffect()
          .toggleStyle(.button)
          .tint(vm.radarVM.compositeRadarVisible ? .primary : .secondary)
          .onChange(of: vm.radarVM.compositeRadarVisible) { oldValue, newValue in
            vm.radarVM.compositeRadarVisible = newValue
          }
        
        Toggle("Satellite", isOn: $vm.radarVM.satelliteRadarVisible)
          .glassEffect()
          .toggleStyle(.button)
          .tint(vm.radarVM.satelliteRadarVisible ? .primary : .secondary)
          .onChange(of: vm.radarVM.satelliteRadarVisible) { oldValue, newValue in
            vm.radarVM.satelliteRadarVisible = newValue
          }
      }
    }
  }
  
  func handleToggle(for item: MapWeatherLayer) async {
    switch item.id {
    case .radar:
      await toggleRadar(value: item.isOn)
    case .sigmet:
      await toggleSigmet(value: item.isOn)
    case .metar:
      toggleMetar()
    case .wxwss:
      toggleWxWSS()
    default:
      print("Other item")
    }
  }
  
  func toggleRadar(value: Bool) async {
    radarVisible = value
    do {
      vm.radarVM.currentRadar = try await RainviewerAPI().fetchRadar()
    } catch let error {
      print(error)
    }
  }
  
  func toggleSigmet(value: Bool) async {
    vm.sigmetsVisible = value
    do {
      vm.sigmets = try await SigmetAPI().fetchSigmet()
    } catch let error {
      print(error)
    }
  }
  
  func toggleMetar() {
    print("Download Metar CSV, update airport icons with colors to represent metar")
  }
  
  func toggleWxWSS() {
    print("Toggle Librewxr WSS")
  }
}

#Preview {
  MapScreenWeatherPanel(vm: .constant(MapViewModel()))
}
