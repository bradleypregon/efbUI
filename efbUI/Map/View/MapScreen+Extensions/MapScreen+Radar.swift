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
  var compositeRadarContent: some MapContent {
    let radarData =
    vm.radarVM.currentRadar?.radar?.nowcast?.first?.path ?? String("/v2/radar/\(Int(Date().timeIntervalSince1970))")
    let mapColor = 4
    let smooth = 1 // 1 or 0
    let snow = 1 // 1 or 0
    let url = String("https://api.librewxr.net\(radarData)/256/{z}/{x}/{y}/\(mapColor)/\(smooth)_\(snow).png")
    
    RasterSource(id: "CompositeRadarSource")
      .tiles([url])
    
    RasterLayer(id: "CompositeRadarLayer", source: "CompositeRadarSource")
      .rasterOpacity(0.7)
      .slot(.middle)
  }
  
  @MapContentBuilder
  var satelliteRadarContent: some MapContent {
    let radarData = vm.radarVM.currentRadar?.satellite?.infrared?.first?.path ?? ""
    // map color and smooth_snow always 0 for satellite
    let url = String("https://api.librewxr.net\(radarData)/256/{z}/{x}/{y}/0/0_0.png")
    
    RasterSource(id: "SatelliteRadarSource")
      .tiles([url])
    
    RasterLayer(id: "SatelliteRadarLayer", source: "SatelliteRadarSource")
      .rasterOpacity(0.7)
      .slot(.middle)
  }
}
