//
//  MapView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//

import SwiftUI
import MapboxMaps

struct MapView: View {
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  
  @State var mapViewModel: MapScreenViewModel
  @State var selectedAirport: AirportTable?
  
  var body: some View {
    MapReader { proxy in
      Map(viewport: $viewport) {
        if mapViewModel.displayLg {
          PointAnnotationGroup(mapViewModel.largeAirports) { airport in
            PointAnnotation(coordinate: CLLocationCoordinate2DMake(airport.lat, airport.long), isDraggable: false)
              .image(named: "lg-airport-vfr")
              .textField(airport.icao)
              .textOffset(x: 0.0, y: -1.8)
              .textColor(.white)
              .textSize(12)
              .onTapGesture { context in
                selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                print(selectedAirport?.airportName ?? "Airport tapped")
                /*
                mapPopoverSelectedPoint = UnitPoint(
                  x:
                    (context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))),
                  y:
                    (context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)))
                )
                */
//                displaySheet.toggle()
                return true
              }
          }
          .slot(Slot.top)
        }
        
        // MARK: Medium Airports
        if mapViewModel.displayMd {
          PointAnnotationGroup(mapViewModel.mediumAirports, id: \.id) { airport in
            PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.lat, longitude: airport.long), isDraggable: false)
              .image(named: "md-airport-vfr")
              .textField(airport.icao)
              .textOffset(x: 0.0, y: -1.9)
              .textColor(.white)
              .textSize(11)
              .onTapGesture { context in
                selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                /*
                mapPopoverSelectedPoint = UnitPoint(
                  x:
                    (context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))),
                  y:
                    (context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)))
                )
                displaySheet.toggle()
                */
                return true
              }
          }
          .clusterOptions(ClusterOptions(clusterRadius: 75.0, clusterMaxZoom: 8.0))
        }
        
        // MARK: Small Airports
        if mapViewModel.displaySm {
          PointAnnotationGroup(mapViewModel.smallAirports) { airport in
            PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.lat, longitude: airport.long), isDraggable: false)
              .image(named: "sm-airport-vfr")
              .textField(airport.icao)
              .textOffset(x: 0.0, y: -1.9)
              .textColor(.white)
              .textSize(9)
              .onTapGesture { context in
                selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                /*
                mapPopoverSelectedPoint = UnitPoint(
                  x:
                    (context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))),
                  y:
                    (context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)))
                )
                displaySheet.toggle()
                */
                return true
              }
              .onLongPressGesture { context in
                /*
                mapPopoverSelectedAirport = airport
                mapPopoverSelectedPoint = UnitPoint(x: (context.point.x / geometry.size.width), y: (context.point.y / (geometry.size.height + 35)))
                */
                return true
              }
          }
          .clusterOptions(ClusterOptions(circleRadius: .constant(12.0), clusterRadius: 75.0, clusterMaxZoom: 6.5))
        }
      }
      .mapStyle(
        MapStyle(uri: StyleURI(rawValue: Bundle.main.object(forInfoDictionaryKey: "MapStyleURIv2") as? String ?? "") ?? .dark)
      )
      .ornamentOptions(ornamentOptions)
      .onStyleLoaded { _ in
        do {
          try proxy.map?.addImage(UIImage(named: "ShipArrow") ?? UIImage(), id: "ShipArrow")
          try proxy.map?.addImage(UIImage(named: "lg-airport-vfr") ?? UIImage(), id: "LgAirportVFR")
          try proxy.map?.addImage(UIImage(named: "TrafficArrow") ?? UIImage(), id: "TrafficArrow")
        } catch {
          print("Error adding image to map: \(error)")
        }
      }
      .onAppear {
        /*
        if airportVM.requestMap {
          Task {
            guard let temp = airportVM.selectedAirport else { return }
            proxy.camera?.ease(to: CameraOptions(center: CLLocationCoordinate2DMake(temp.airportRefLat, temp.airportRefLong), zoom: 13), duration: 1.25)
            airportVM.requestMap = false
          }
        }
        */
        
      }
    }
    .ignoresSafeArea()
  }
}

#Preview {
  MapView(mapViewModel: MapScreenViewModel())
}
