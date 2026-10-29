//
//  MapScreen+Radar.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/10/26.
//

import SwiftUI
import MapboxMaps

/*
 todos
 - radar time slider
 - get satellite working (and also slider?)
 */

extension MapScreen {
  @MapContentBuilder
  var radarContent: some MapContent {
    let radarData:Int = vm.radarSectionVM.currentRadar?.radar?.nowcast?.first?.time ?? Int(Date().timeIntervalSince1970)
    let mapColor = 4
    let smooth = 1 // 1 or 0
    let snow = 1 // 1 or 0
    let url = String("https://api.librewxr.net/v2/radar/\(radarData)/256/{z}/{x}/{y}/\(mapColor)/\(smooth)_\(snow).png")
    
    RasterSource(id: "RadarSource")
      .tiles([url])
    
    RasterLayer(id: "RadarLayer", source: "RadarSource")
      .rasterOpacity(0.4)
  }

  func addSatelliteRadarSource() {
    if let currentRadar = vm.radarSectionVM.currentRadar {

      let radarData = currentRadar.satellite?.infrared?.first?.path ?? ""
      let stringPaths = "{z}/{x}/{y}"
      let mapColor = "0"
      let options = "0_0" // smooth_snow always 0 for satellite
      let url = String("https://tilecache.rainviewer.com\(radarData)/512/\(stringPaths)/\(mapColor)/\(options).png")
      
      var rasterSource = RasterSource(id: vm.radarSectionVM.satelliteRadarSourceID)
      rasterSource.tiles = [url]
      rasterSource.tileSize = 512
      
      var rasterLayer = RasterLayer(id: vm.radarSectionVM.satelliteRadarSourceID, source: rasterSource.id)
      rasterLayer.rasterOpacity = .constant(0.4)
      
      do {
        try proxyMap?.map?.addSource(rasterSource)
        try proxyMap?.map?.addLayer(rasterLayer)
      } catch {
        vm.radarSectionVM.rasterRadarAlertVisible = true
        print("Failed to update map style with Satellite or Wx Radar: \(error)")
      }
    }
  }
  
  func removeSatelliteRadarSource() {
    do {
      try proxyMap?.map?.removeLayer(withId: vm.radarSectionVM.satelliteRadarSourceID)
      try proxyMap?.map?.removeSource(withId: vm.radarSectionVM.satelliteRadarSourceID)
    } catch {
      print("Failed to remove satellite source: \(error)")
    }
  }
}
