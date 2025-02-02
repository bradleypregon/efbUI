//
//  MapScreen+Extensions.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/30/25.
//

import SwiftUI
import MapboxMaps
import Observation

// MARK: SimConnect Traffic
extension MapScreen {
  func tempUpdateOwnship(ship: SimConnectShip, proxy: MapProxy) async {
    do {
      try proxy.map?.updateLayer(withId: "OwnshipLayer", type: LocationIndicatorLayer.self) { layer in
        layer.location = .constant([ship.coordinate.latitude, ship.coordinate.longitude, ship.altitude])
        layer.bearing = .constant(ship.heading)
      }
    } catch {
      print("Error updating ownship layer to MapScreen: \(error)")
    }
  }
  
  func tempUpdateTraffic(traffic: [SimConnectShip], proxy: MapProxy) async {
    // loop through simconnect.traffic
    // update anything already created
    //  if not created, create
    //  check prune traffic
    
    for tfc in traffic {
      if (proxy.map?.layerExists(withId: String(describing: tfc.fs2ffid)) != nil) {
        updateTrafficLayer(id: String(describing: tfc.fs2ffid), ship: tfc, proxy: proxy)
        
        if self.featureCollection.features.contains(where: { $0.identifier == .string(String(describing: tfc.fs2ffid)) }) {
          updateTrafficFeature(traffic: tfc, proxy: proxy)
        } else {
          addTrafficFeature(traffic: tfc)
        }
      } else {
        addTrafficLayer(id: String(describing: tfc.fs2ffid), proxy: proxy)
      }
      
    }
    if simConnect.pruneTrafficArray.value != [] {
      for tfc in simConnect.pruneTrafficArray.value {
        pruneTrafficLayer(id: String(describing: tfc.fs2ffid), proxy: proxy)
        removeTrafficFeature(id: String(describing: tfc.fs2ffid))
      }
    }
  }
  
  func addTrafficFeature(traffic: SimConnectShip) {
    var feature = Feature(geometry: .point(Point(traffic.coordinate)))
    feature.identifier = .string(String(describing: traffic.fs2ffid))
    feature.properties = ["reg": .init(stringLiteral: traffic.registration ?? ""), "alt": .init(floatLiteral: traffic.altitude), "onGround": .init(booleanLiteral: traffic.onGround ?? false)]
    self.featureCollection.features.append(feature)
  }
  
  func updateTrafficFeature(traffic: SimConnectShip, proxy: MapProxy) {
    self.featureCollection.features.forEach { feature in
      var updatedFeature = Feature(geometry: .point(Point(traffic.coordinate)))
      updatedFeature.identifier = .string(String(describing: traffic.fs2ffid))
      updatedFeature.properties = ["reg": .init(stringLiteral: traffic.registration ?? ""), "alt": .init(floatLiteral: traffic.altitude), "onGround": .init(booleanLiteral: traffic.onGround ?? false)]
      
      proxy.map?.updateGeoJSONSourceFeatures(forSourceId: "TrafficTextID", features: [updatedFeature])
    }
  }
  
  func removeTrafficFeature(id: String) {
    self.featureCollection.features.removeAll { $0.identifier?.string == id }
  }
  
  func addOwnshipLayer() {
    do {
      var layer = LocationIndicatorLayer(id: "OwnshipLayer")
      layer.topImage = .constant(ResolvedImage.name("ShipArrow"))
      layer.slot = .top
      try proxyMap?.map?.addLayer(layer)
    } catch {
      print("Error adding ownship layer to MapScreen: \(error)")
    }
  }
  
  func updateTrafficLayer(id: String, ship: SimConnectShip, proxy: MapProxy) {
    do {
      try proxy.map?.updateLayer(withId: id, type: LocationIndicatorLayer.self) { layer in
        layer.location = .constant([ship.coordinate.latitude, ship.coordinate.longitude, ship.altitude])
        layer.bearing = .constant(ship.heading)
      }
    } catch {
      print("Error updating traffic layer for ID: \(id): \(error)")
      addTrafficLayer(id: id, proxy: proxy)
    }
  }
  
  func addTrafficLayer(id: String, proxy: MapProxy) {
    do {
      var layer = LocationIndicatorLayer(id: id)
      layer.topImage = .constant(ResolvedImage.name("TrafficArrow"))
      layer.slot = .middle
      try proxy.map?.addLayer(layer)
    } catch {
      print("Error adding traffic layer for id: \(id): \(error)")
    }
  }
  
  func pruneTrafficLayer(id: String, proxy: MapProxy) {
    guard let tfcID = Int(id) else {
      print("err casting traffic id")
      return
    }
    do {
      try proxy.map?.removeLayer(withId: id)
      simConnect.pruneTrafficArray.value.removeAll(where: { $0.fs2ffid == tfcID })
      print("Pruned traffic in MapScreen: \(id)")
    } catch {
      print("Unable to remove pruned traffic layer for id: \(id): \(error)")
    }
    simConnect.pruneTrafficArray.value.removeAll(where: { $0.fs2ffid == tfcID })
  }
}

// MARK: Weather and Satellite Radar
extension MapScreen {
  // MARK: addRasterRadarSource
  func addWeatherRadarSource() {
    // https://api.rainviewer.com/public/weather-maps.json
    /// image/mapsize/stringpaths (x,y,z)/mapcolor/options(smooth_snow)/filetype
    if let currentRadar = mapViewModel.currentRadar {
      let radarData = currentRadar.radar?.nowcast?.first?.path ?? ""
      let stringPaths = "{z}/{x}/{y}"
      let mapColor = "4"
      let options = "1_1" // smooth_snow
      let url = String("https://tilecache.rainviewer.com\(radarData)/512/\(stringPaths)/\(mapColor)/\(options).png")
      
      var rasterSource = RasterSource(id: mapViewModel.wxRadarSourceID)
      rasterSource.tiles = [url]
      rasterSource.tileSize = 512
      
      var rasterLayer = RasterLayer(id: mapViewModel.wxRadarSourceID, source: rasterSource.id)
      rasterLayer.rasterOpacity = .constant(0.4)
      
      do {
        try proxyMap?.map?.addSource(rasterSource)
        try proxyMap?.map?.addLayer(rasterLayer)
      } catch {
        rasterRadarAlertVisible = true
        print("Failed to update map style with Wx Radar: \(error)")
      }
    }
  }
  
  // MARK: removeRasterRadarSource
  func removeWeatherRadarSource() {
    do {
      try proxyMap?.map?.removeLayer(withId: mapViewModel.wxRadarSourceID)
      try proxyMap?.map?.removeSource(withId: mapViewModel.wxRadarSourceID)
    } catch {
      print("Failed to remove radar source. Error: \(error)")
    }
  }
  
  func addSatelliteRadarSource() {
    if let currentRadar = mapViewModel.currentRadar {

      let radarData = currentRadar.satellite?.infrared?.first?.path ?? ""
      let stringPaths = "{z}/{x}/{y}"
      let mapColor = "0"
      let options = "0_0" // smooth_snow always 0 for satellite
      let url = String("https://tilecache.rainviewer.com\(radarData)/512/\(stringPaths)/\(mapColor)/\(options).png")
      
      var rasterSource = RasterSource(id: mapViewModel.satelliteRadarSourceID)
      rasterSource.tiles = [url]
      rasterSource.tileSize = 512
      
      var rasterLayer = RasterLayer(id: mapViewModel.satelliteRadarSourceID, source: rasterSource.id)
      rasterLayer.rasterOpacity = .constant(0.4)
      
      do {
        try proxyMap?.map?.addSource(rasterSource)
        try proxyMap?.map?.addLayer(rasterLayer)
      } catch {
        rasterRadarAlertVisible = true
        print("Failed to update map style with Satellite or Wx Radar: \(error)")
      }
    }
  }
  
  func removeSatelliteRadarSource() {
    do {
      try proxyMap?.map?.removeLayer(withId: mapViewModel.satelliteRadarSourceID)
      try proxyMap?.map?.removeSource(withId: mapViewModel.satelliteRadarSourceID)
    } catch {
      print("Failed to remove satellite source: \(error)")
    }
  }
}

// MARK: Deprecated Functions
extension MapScreen {
  // handleCameraChange
  /**
   Handle zoom level changes and load map annotations
   - Large  Airport Threshold: 5.25
   - Medium  Airport Threshold: 6.0
   - Small Airport Threshold: 6.5
   - Airport Gate Threshold: 14.0
   */
  func handleCameraChange(zoom: CGFloat, bounds: CoordinateBounds) {
    if zoom >= 11.0 { return }
    let lgAirportThreshold: CGFloat = 5.0
    let mdAirportThreshold: CGFloat = 6.0
    let smAirportThreshold: CGFloat = 6.5
    
    if zoom >= lgAirportThreshold {
//      loadAirports(bounds: bounds, size: "Large")
//      airportJSONModel.fetchVisibleAirports(size: "Large", bounds: bounds)
//      mapViewModel.fetchLargeAirports(bounds: bounds)
    } else if zoom < lgAirportThreshold {
//      removeAirports(size: "Large")
//      airportJSONModel.hideAirports(size: "Large")
//      mapViewModel.hideLargeAirports()
    }
    if zoom >= mdAirportThreshold {
//      loadAirports(bounds: bounds, size: "Medium")
//      airportJSONModel.fetchVisibleAirports(size: "Medium", bounds: bounds)
//      mapViewModel.fetchMediumAirports(bounds: bounds)
    } else if zoom < mdAirportThreshold {
//      removeAirports(size: "Medium")
//      airportJSONModel.hideAirports(size: "Medium")
//      mapViewModel.hideMediumAirports()
    }
    if zoom >= smAirportThreshold {
//      loadAirports(bounds: bounds, size: "Small")
//      airportJSONModel.fetchVisibleAirports(size: "Small", bounds: bounds)
//      mapViewModel.fetchSmallAirports(bounds: bounds)
    } else if zoom < smAirportThreshold {
//      removeAirports(size: "Small")
//      airportJSONModel.hideAirports(size: "Small")
//      mapViewModel.hideSmallAirports()
    }
    
  }
  
  // MARK: calculateVisibleMapRegion
  func calculateVisibleMapRegion(center: CLLocationCoordinate2D, zoom: CGFloat, geometry: GeometryProxy) -> CoordinateBounds {
    // TODO: Handle errors when zoomed out and panning to North or South pole
    // TODO: Fix calculation - not covering all of what is visible on map
    let aspectRatio = Double(geometry.size.width / geometry.size.height)
    // landscape: > 1 | portrait: < 1
    var spanLong = 0.0
    var spanLat = 0.0
    if aspectRatio < 1 {
      spanLong = 360.0 / pow(2.0, zoom) * aspectRatio
      spanLat = 180.0 / pow(2.0, zoom) / aspectRatio
    } else {
      spanLong = 360.0 / pow(2.0, zoom) * aspectRatio - geometry.safeAreaInsets.leading
      spanLat = 180.0 / pow(2.0, zoom) * aspectRatio
    }
    
    let sw = CLLocationCoordinate2D(latitude: center.latitude - spanLat, longitude: center.longitude - spanLong)
    let ne = CLLocationCoordinate2D(latitude: center.latitude + spanLat, longitude: center.longitude + spanLong)
    
    let coordBounds = CoordinateBounds(southwest: sw, northeast: ne)
    
    return coordBounds
  }
  
}
