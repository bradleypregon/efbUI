//
//  MKViewRepresentable.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/12/23.
//
/*
import SwiftUI
import MapKit

struct SwiftMapView: UIViewRepresentable {
  @State var airportAnnotations = Set<AirportAnnotation>()
  
  @Binding var largeAirportAnnotationsLoaded: Bool
  @Binding var medAirportAnnotationsLoaded: Bool
  @Binding var smallAirportAnnotationsLoaded: Bool
  
  @Binding var mapStyle: MapStyle
  @ObservedObject var simConnect: SimConnect
  
  @Binding var selectedTab: Int
  @Binding var airports: Set<Airport>
  
  private let region = MKCoordinateRegion(
    center:
      CLLocationCoordinate2D(
        latitude: 40,
        longitude: -90),
    span:
      MKCoordinateSpan(
        latitudeDelta: 35,
        longitudeDelta: 35)
  )
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    
    mapView.region = region
    mapView.showsTraffic = false
    mapView.showsBuildings = false
    mapView.pointOfInterestFilter = nil
    mapView.isPitchEnabled = true
    mapView.showsUserLocation = false
    
    mapView.delegate = context.coordinator
    
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    switch mapStyle {
    case .standard:
      view.mapType = .standard
    case .mutedStandard:
      view.mapType = .mutedStandard
    case .satellite:
      view.mapType = .satelliteFlyover
    case .hybrid:
      view.mapType = .hybridFlyover
    }
    
    let airplaneAnnotation = view.annotations.filter { $0 is AirplaneAnnotation }
    
    // dispatch queue
    view.removeAnnotations(airplaneAnnotation)
//    view.addAnnotation(simConnect.airplaneAnnotation)
    
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
}


class Coordinator: NSObject, MKMapViewDelegate {
  
  var parent: SwiftMapView
  var simConnect: SimConnect?
  
  init(_ parent: SwiftMapView) {
    self.parent = parent
  }
  
  // MARK: mapView(viewFor Annotation)
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if let airplaneAnnotation = annotation as? AirplaneAnnotation {
      let reuseIdentifier = "AirplaneAnnotationView"
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? AirplaneAnnotationView
      
      if annotationView == nil {
        annotationView = AirplaneAnnotationView(annotation: airplaneAnnotation, reuseID: reuseIdentifier)
      }
      let image = UIImage(named: "ownship")
      let newImage = image?.rotate(angle: .degrees(airplaneAnnotation.heading))
      annotationView?.image = newImage
      
      return annotationView
    }
    
    else if let airportAnnotation = annotation as? AirportAnnotation {
      let reuseID = "AirportPin"
      
      var airportAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
      
      if airportAnnotationView == nil {
        airportAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
      } else {
        airportAnnotationView?.annotation = annotation
      }
      
      airportAnnotationView?.canShowCallout = true
      airportAnnotationView?.image = getAirportIcon(airportSize: airportAnnotation.properties.size.rawValue)
      
      airportAnnotationView?.detailCalloutAccessoryView = UIView()
      
      return airportAnnotationView
    }
    
    return nil
  }
  
  func getAirportIcon(airportSize: String) -> UIImage? {
    // [sm, md, lg]-airport-[default, vfr, mvfr, ifr, lifr]
    switch airportSize {
    case "Large":
      let image = UIImage(named: "lg-airport-default")
      let newImage = image?.resize(newWidth: 44)
      return newImage
    case "Medium":
      let image = UIImage(named: "md-airport-default")
      let newImage = image?.resize(newWidth: 40)
      return newImage
    default:
      let image = UIImage(named: "sm-airport-default")
      let newImage = image?.resize(newWidth: 32)
      return newImage
    }
  }
  
  // MARK: mapView(didSelect)
//  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    if let selectedAnnotation = view.annotation as? AirportAnnotation {
//      
//      guard let filteredAirport = parent.airports.first?.filter({$0.properties.faa == selectedAnnotation.properties.faa}) else { return }
//      
//      let airportCalloutView = AirportAnnotationCalloutView(
//        selectedTab: parent.$selectedTab,
//        locationData: selectedAnnotation,
//        filteredAirport: filteredAirport
//      )
//      
//      let callout = MapCalloutView(rootView: AnyView(airportCalloutView))
//      view.detailCalloutAccessoryView = callout
//    }
//  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    let zoomLevel = getZoomLevel(mapView: mapView)
    
    let largeAnnotationThreshold: Double = 5.5 // further zoomed out
    let medAnnotationThreshold: Double = 7.0 // medium zoom
    let smallAnnotationThreshold: Double = 8.0 // close zoom
    
    let largeAnnotations = parent.airportAnnotations.filter { $0.properties.size.rawValue == "Large" }
    let mediumAnnotations = parent.airportAnnotations.filter { $0.properties.size.rawValue == "Medium" }
    let smallAnnotations = parent.airportAnnotations.filter { $0.properties.size.rawValue == "Small" }
    
    // if zooming in and past large annotation threshold and largeanntation is not loaded
    if zoomLevel >= largeAnnotationThreshold && !parent.largeAirportAnnotationsLoaded {
      loadAirportAnnotations(mapView: mapView, size: "Large", zoomLevel: zoomLevel)
      parent.largeAirportAnnotationsLoaded = true
    }
    if zoomLevel >= medAnnotationThreshold && !parent.medAirportAnnotationsLoaded {
      loadAirportAnnotations(mapView: mapView, size: "Medium", zoomLevel: zoomLevel)
      parent.medAirportAnnotationsLoaded = true
    }
    if zoomLevel >= smallAnnotationThreshold && !parent.smallAirportAnnotationsLoaded {
      loadAirportAnnotations(mapView: mapView, size: "Small", zoomLevel: zoomLevel)
      parent.smallAirportAnnotationsLoaded = true
    }
    
    if zoomLevel <= smallAnnotationThreshold && parent.smallAirportAnnotationsLoaded {
      
      mapView.removeAnnotations(Array(smallAnnotations))
      parent.smallAirportAnnotationsLoaded = false
    }
    if zoomLevel <= medAnnotationThreshold && parent.medAirportAnnotationsLoaded {
      mapView.removeAnnotations(Array(mediumAnnotations))
      parent.medAirportAnnotationsLoaded = false
    }
    if zoomLevel <= largeAnnotationThreshold && parent.largeAirportAnnotationsLoaded {
      mapView.removeAnnotations(Array(largeAnnotations))
      parent.largeAirportAnnotationsLoaded = false
    }
  }
  
  private func getZoomLevel(mapView: MKMapView) -> Double {
    let viewRegion = mapView.region
    let horizontalMeters = viewRegion.span.longitudeDelta
    let horizontalZoomLevel = log2(360 * (Double(mapView.frame.size.width) / horizontalMeters)) - 8
    let verticalMeters = viewRegion.span.latitudeDelta
    let verticalZoomLevel = log2(360 * (Double(mapView.frame.size.height) / verticalMeters)) - 8
    return min(horizontalZoomLevel, verticalZoomLevel)
  }
  
  private func loadAirportAnnotations(mapView: MKMapView, size: String, zoomLevel: Double) {
    let visibleRegion = mapView.visibleMapRect
    
    let visibleAnnotations = parent.airports.filter { airport in
      let coordinate = CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long)
      let point = MKMapPoint(coordinate)
      
      let isVisible = visibleRegion.contains(point)
      let isCorrectSize = airport.properties.size.rawValue == size
      
      return isVisible && isCorrectSize
    }
    
    for result in visibleAnnotations {
      let airportAnnotation = AirportAnnotation(
        coordinate: CLLocationCoordinate2D(
          latitude: result.coordinates.lat,
          longitude: result.coordinates.long
        ),
        properties: result.properties
      )
      
      parent.airportAnnotations.insert(airportAnnotation)
      mapView.addAnnotation(airportAnnotation)
    }
  }
  
}
*/
