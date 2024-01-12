//
//  MapboxView.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/9/23.
//

import SwiftUI
import MapboxMaps

//struct MapboxView: UIViewRepresentable {
//  let mapView = MapView(frame: .zero)
//  
//  func makeUIView(context: Context) -> MapView {
//    mapView.mapboxMap.styleURI = StyleURI(rawValue: "mapbox-custom-url")
//    return mapView
//  }
//  
//  func updateUIView(_ uiView: UIViewType, context: Context) { }
//  
//}

struct MapboxView: UIViewRepresentable {
  let mapView = MapView(frame: .zero)
  
  func makeUIView(context: Context) -> MapView {
    let defaultCamera = CameraOptions(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 3, bearing: 0, pitch: 0)
    mapView.mapboxMap.styleURI = StyleURI(rawValue: "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6")
    mapView.mapboxMap.setCamera(to: defaultCamera)
    mapView.ornaments.options.scaleBar.visibility = .hidden
    mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    return mapView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) { }
  
}
