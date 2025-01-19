//
//  ContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import MapboxMaps
import Observation
import PencilKit

struct MapScreen: View {
  @Binding var selectedTab: efbTab
  @Environment(SimConnectShipObserver.self) private var simConnect
//  @Environment(Settings.self) private var settings
  @Environment(SimBriefViewModel.self) private var simbrief
  @Environment(AirportScreenViewModel.self) private var airportVM
  @Environment(RouteManager.self) private var routeManager
  
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  private let style = "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6"
  
  @State private var mapViewModel = MapScreenViewModel()
  
  @State private var selectedAirport: AirportTable?
  @State private var proxyMap: MapProxy? = nil
  @State private var currentZoom: CGFloat = 3.0

  @State private var rasterRadarAlertVisible: Bool = false
  
  @State private var drawingEnabled: Bool = false
  @State private var canvas = PKCanvasView()
  
  @State private var waypointPopoverVisible: Bool = false
  
  @GestureState private var sigmetLongPress = false
  @State private var sigmetMenuPopoverVisible: Bool = false
  @State private var sigmetSliderRange: ClosedRange<Float> = 1000...41000
  
  @State private var mapPopoverSelectedAirport: AirportSchema? = nil
  @State private var mapPopoverSelectedPoint: UnitPoint = .zero
  
  @State var featureCollection: FeatureCollection = .init(features: [])
  
  @State var radarPopoverVisible: Bool = false
  @State var displaySheet: Bool = false
  
  var body: some View {
    ZStack {
      GeometryReader { geometry in
        MapReader { proxy in
          Map(viewport: $viewport) {
            // MARK: Airport Annotations
            // MARK: Large Airports
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
                    mapPopoverSelectedPoint = UnitPoint(
                      x: (context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))),
                      y: (context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom)))
                    )
                    displaySheet.toggle()
                    return true
                  }
//                    .onLongPressGesture { context in
//                      mapPopoverSelectedAirport = airport
//                      mapPopoverSelectedPoint = UnitPoint(x: (context.point.x / geometry.size.width), y: (context.point.y / (geometry.size.height + 35)))
//                      return true
//                    }
              }
              .slot("Top")
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
                    mapPopoverSelectedPoint = UnitPoint(
                      x: (
                        context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))
                      ),
                      y: (
                        context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom))
                      )
                    )
                    displaySheet.toggle()
                    return true
                  }
//                    .onLongPressGesture { context in
//                      mapPopoverSelectedAirport = airport
//                      mapPopoverSelectedPoint = UnitPoint(x: (context.point.x / geometry.size.width), y: (context.point.y / (geometry.size.height + 35)))
//                      return true
//                    }
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
                    mapPopoverSelectedPoint = UnitPoint(
                      x: (
                        context.point.x / (geometry.size.width - (geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing))
                      ),
                      y: (
                        context.point.y / (geometry.size.height - (geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom))
                      )
                    )
                    displaySheet.toggle()
                    return true
                  }
                  .onLongPressGesture { context in
                    mapPopoverSelectedAirport = airport
                    mapPopoverSelectedPoint = UnitPoint(x: (context.point.x / geometry.size.width), y: (context.point.y / (geometry.size.height + 35)))
                    return true
                  }
              }
              .clusterOptions(ClusterOptions(circleRadius: .constant(12.0), clusterRadius: 75.0, clusterMaxZoom: 6.5))
            }
            
            // MARK: Route Display
//              if mapViewModel.displayRoute {
//                if let navlog = simbrief.ofp?.navlog {
//                  PolylineAnnotationGroup {
//                    PolylineAnnotation(lineCoordinates: navlog.map { CLLocationCoordinate2D(latitude: Double($0.lat) ?? .zero, longitude: Double($0.long) ?? .zero)})
//                      .lineWidth(2)
//                      .lineColor(.blue)
//                  }
//                  ForEvery(navlog.filter { $0.type != "apt" }, id:\.id) { wpt in
//                    MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(wpt.lat) ?? .zero, longitude: Double(wpt.long) ?? .zero)) {
//                      MapScreenWaypointView(wpt: wpt)
//                    }
//                    .allowOverlap(wpt.ident == "TOC" || wpt.ident == "TOD" ? true : false)
//                    .ignoreCameraPadding(true)
//                  }
//                }
//              }
            
            if mapViewModel.displayNewRoute {
              PolylineAnnotation(lineCoordinates: routeManager.waypoints.map { CLLocationCoordinate2DMake($0.lat, $0.long) })
                .lineWidth(3.0)
                .lineColor(.white)
              ForEvery(routeManager.waypoints.filter { $0.type != .airport }) { wpt in
                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: wpt.lat, longitude: wpt.long)) {
                  MapScreenWaypointView(wpt: wpt)
                }
              }
            }
            
            // MARK: Sigmet Data
            // CONVECTIVE: orange, IFR: blue, MTN OBSCN: gray, TURB: red
            if mapViewModel.displaySigmet {
              PolygonAnnotationGroup(mapViewModel.sigmets.filter { !$0.coords.isEmpty }, id: \.airSigmetId) { sigmet in
                var polyCoords: [CLLocationCoordinate2D] = []
                
                for coord in sigmet.coords {
                  if let hiAlt = sigmet.altitudeHi2, let loAlt = sigmet.altitudeLow1 {
                    if hiAlt < Int(sigmetSliderRange.upperBound) && loAlt > Int(sigmetSliderRange.lowerBound) {
                      polyCoords.append(CLLocationCoordinate2DMake(coord.lat, coord.lon))
                    }
                  }
                  
                }
                
                let polygon = Polygon([polyCoords])
                return PolygonAnnotation(polygon: polygon, isDraggable: false)
                  .fillOpacity(0.09)
                  .fillColor(getSigmetFillColor(sigmet: sigmet.hazard))
                  .onTapGesture {
                    // testing purposes
                    print("hz: \(sigmet.hazard)")
                    print("low alt: \(sigmet.altitudeLow1 ?? .zero)")
                    print("low alt2: \(sigmet.altitudeLow2 ?? .zero)")
                    print("hi alt: \(sigmet.altitudeHi1 ?? .zero)")
                    print("hi alt2: \(sigmet.altitudeHi2 ?? .zero)")
                  }
                  
              }
            }
            
            if mapViewModel.displaySID {
              ForEvery(mapViewModel.sidRoute, id: \.self) { route in
                let temp = Array(Dictionary(grouping: route, by:{ $0.transitionIdentifier}).values)
                PolylineAnnotationGroup(temp, id: \.self) { line in
                  PolylineAnnotation(lineCoordinates: line.map{CLLocationCoordinate2D(latitude: $0.waypointLatitude, longitude: $0.waypointLongitude)})
                    .lineColor(line.allSatisfy { $0.aircraftCategory != "" } ? .orange : .blue)
                    .lineWidth(4.0)
                }
                
                ForEvery(temp.flatMap{$0}.filter{$0.waypointDescriptionCode.contains("E")}, id:\.self) { val in
                  MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: val.waypointLatitude, longitude: val.waypointLongitude)) {
                    Button {
                      print("\(val.procedureIdentifier)/\(val.waypointIdentifier)")
                    } label: {
                      Text("\(val.procedureIdentifier)/\(val.waypointIdentifier)")
                        .font(.caption)
                    }
                    .controlSize(.small)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                  }
                  .allowOverlap(true)
                  
                }
              }
            }

            if mapViewModel.displaySTAR {
              ForEvery(mapViewModel.starRoute, id: \.self) { route in
                let temp = Array(Dictionary(grouping: route, by:{ $0.transitionIdentifier}).values)
                PolylineAnnotationGroup(temp, id: \.self) { line in
                  PolylineAnnotation(lineCoordinates: line.map{CLLocationCoordinate2D(latitude: $0.waypointLatitude, longitude: $0.waypointLongitude)})
                    .lineColor(line.allSatisfy { $0.aircraftCategory != "" } ? .orange : .blue)
                    .lineWidth(4.0)
                }
                
                ForEvery(temp.flatMap{$0}.filter{$0.transitionIdentifier == $0.waypointIdentifier}, id:\.self) { val in
                  MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: val.waypointLatitude, longitude: val.waypointLongitude)) {
                    Button {
                      print("\(val.procedureIdentifier)/\(val.waypointIdentifier)")
                    } label: {
                      Text("\(val.procedureIdentifier)/\(val.waypointIdentifier)")
                        .font(.caption)
                    }
                    .controlSize(.small)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                  }
                  .allowOverlap(true)
                }
              }
            }
            
            if !featureCollection.features.isEmpty {
              GeoJSONSource(id: "TrafficTextID")
                .data(.featureCollection(self.featureCollection))
              SymbolLayer(id: "TrafficRegLayerID", source: "TrafficTextID")
                .textField(Exp(.get) { "reg" })
                .textOffset(x: 0, y: 1.8)
                .textSize(7)
                .textColor(.white)
                .textFont(["Roboto Bold Condensed"])
              SymbolLayer(id: "TrafficAltLayerID", source: "TrafficTextID")
                .textField(Exp(.get) { "alt" })
                .textSize(7)
                .textOffset(x: 0, y: -1.8)
                .textColor(.white)
                .textFont(["Roboto Bold Condensed"])
            }
            
            if mapViewModel.enrouteCommsVisible {
              PointAnnotationGroup(mapViewModel.enrouteComms, id: \.self) { point in
                PointAnnotation(coordinate: CLLocationCoordinate2DMake(point.latitude, point.longitude))
                  .textField("\(point.communicationFrequency)")
                  .textColor(.white)
                  .textSize(12)
              }
            }
            
            // WIP
//              if mapViewModel.gatesVisible {
//                PointAnnotationGroup(mapViewModel.visibleGates, id: \.gateIdentifier) { gate in
//                  PointAnnotation(coordinate: CLLocationCoordinate2DMake(gate.gateLatitude, gate.gateLongitude))
//                    .textField(gate.name)
//                    .textColor(.white)
//                    .textSize(12)
//                }
//              }
          }
          .mapStyle(.init(uri: StyleURI(rawValue: style) ?? StyleURI.dark))
          .ornamentOptions(ornamentOptions)
          .onStyleLoaded { _ in
            do {
              try proxy.map?.addImage(UIImage(named: "ShipArrow") ?? UIImage(), id: "ShipArrow")
              try proxy.map?.addImage(UIImage(named: "TrafficArrow") ?? UIImage(), id: "TrafficArrow")
              addOwnshipLayer()
            } catch {
              print("Error adding image to map: \(error)")
            }
          }
          .onCameraChanged { context in
            if context.cameraState.zoom >= 6 {
              if mapViewModel.enrouteCommsVisible {
                // TODO: This will be taxing. We don't really need to query *every* time the camera changes
                // filtering a lot out for now
                guard let bounds = proxy.map?.cameraBounds.bounds else { return }
                Task {
                  mapViewModel.enrouteComms = await SQLiteManager.shared.getEnrouteComms(in: bounds)
                }
              }
            }
            
            if context.cameraState.zoom >= 7.5 {
//                mapViewModel.gatesVisible = true
//                mapViewModel.fetchVisibleGates()
            } else {
//                mapViewModel.gatesVisible = false
            }
          }
          .onAppear {
            proxyMap = proxy
            if airportVM.requestMap {
              Task {
                guard let temp = airportVM.selectedAirport else { return }
                proxy.camera?.ease(to: CameraOptions(center: CLLocationCoordinate2DMake(temp.airportRefLat, temp.airportRefLong), zoom: 13), duration: 1.25)
                airportVM.requestMap = false
              }
            }
          }
          .alert("Radar Error", isPresented: $rasterRadarAlertVisible) {
            Button("Ok") {
              // TODO: Handle retrying radar
              mapViewModel.displayRadar = false
            }
          }
          .popover(item: $mapPopoverSelectedAirport, attachmentAnchor: PopoverAttachmentAnchor.point(mapPopoverSelectedPoint)) { airport in
            let sids = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_sids")
            let stars = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_stars")
            
            VStack {
              Text(airport.name)
              
              Button {
                print("View Airport (INOP)")
              } label: {
                Text("View Airport")
              }
              
              Menu("View Procedures") {
                if (!sids.isEmpty) {
                  Button {
                    let filteredSIDs = sids.filter{!$0.transitionIdentifier.starts(with: "RW") && $0.transitionIdentifier != "ALL" }
                    let grouped = Dictionary(grouping: filteredSIDs, by: { $0.procedureIdentifier })
                    mapViewModel.sidRoute = Array(grouped.values)
                    mapViewModel.displaySID.toggle()
                  } label: {
                    Text("View SIDs")
                  }
                }
                
                if (!stars.isEmpty) {
                  Button {
                    let filteredSTARs = stars.filter{!$0.transitionIdentifier.starts(with: "RW") && $0.transitionIdentifier != "ALL" }
                    let grouped = Dictionary(grouping: filteredSTARs, by: { $0.procedureIdentifier })
                    mapViewModel.starRoute = Array(grouped.values)
                    mapViewModel.displaySTAR.toggle()
                  } label: {
                    Text("View STARs")
                  }
                }
                
              }
            }
            .frame(idealWidth: 150, idealHeight: 300)
            
          }
          .onReceive(simConnect.ownship) { ship in
            Task {
              await tempUpdateOwnship(ship: ship, proxy: proxy)
            }
          }
          .onReceive(simConnect.trafficArray) { traffic in
            Task {
              await tempUpdateTraffic(traffic: traffic, proxy: proxy)
            }
          }
          .popover(item: $selectedAirport, attachmentAnchor: PopoverAttachmentAnchor.point(mapPopoverSelectedPoint)) { airport in
            AirportAnnotationCalloutView(selectedTab: $selectedTab, airport: airport)
              .frame(width: 300, height: 375)
          }
//            .sheet(item: $selectedAirport) { airport in
//              AirportAnnotationCalloutView(selectedTab: $selectedTab, airport: airport)
//            .frame(width: 300, height: 375)
//            }
        }
        .ignoresSafeArea()
        
        // MARK: Menu
        VStack(spacing: 5) {
          Button {
            // display popover
            radarPopoverVisible.toggle()
          } label: {
            Image(systemName: "cloud.sun")
          }
          .task(id: radarPopoverVisible) {
            // TODO: Cleanup the currentRadar optional date comparison
            // TODO: Use ViewModel fetchRadar function instead of using View
            if radarPopoverVisible && mapViewModel.currentRadar?.generated ?? Int(Date().timeIntervalSinceNow) < (Int(Date().timeIntervalSinceNow) + Int(5*60)) {
              let rainviewerAPI = RainviewerAPI()
              do {
                mapViewModel.currentRadar = try await rainviewerAPI.fetchRadar()
              } catch {
                print("Error fetching current radar: \(error)")
              }
            }
          }
          .popover(isPresented: $radarPopoverVisible) {
            VStack {
              // Weather Radar
              Button {
                mapViewModel.displayRadar.toggle()
                mapViewModel.displayRadar ? addWeatherRadarSource() : removeWeatherRadarSource()
              } label: {
                Text("Wx Radar")
              }
              // Satellite Radar
              Button {
                mapViewModel.displaySatelliteRadar.toggle()
                mapViewModel.displaySatelliteRadar ? addSatelliteRadarSource() : removeSatelliteRadarSource()
              } label: {
                Text("Satellite")
              }
            }
          }
          
          Toggle("Route", systemImage: mapViewModel.displayRoute ? "point.topleft.down.to.point.bottomright.curvepath.fill" : "point.topleft.down.to.point.bottomright.curvepath", isOn: $mapViewModel.displayRoute)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          Toggle("NewRoute", systemImage: mapViewModel.displayNewRoute ? "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath.fill" : "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", isOn: $mapViewModel.displayNewRoute)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          // TODO: Fix long press gesture not working properly
          // Fixed: Added button in bottom-left to control altitudes
          Toggle("Sigmet", systemImage: mapViewModel.displaySigmet ? "hazardsign.fill" : "hazardsign", isOn: $mapViewModel.displaySigmet)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .task(id: mapViewModel.displaySigmet) {
              if mapViewModel.displaySigmet {
                let sigmetAPI = SigmetAPI()
                do {
                  mapViewModel.sigmets = try await sigmetAPI.fetchSigmet()
                } catch {
                  print("Error fetching Sigmet API: \(error)")
                }
              } else {
                mapViewModel.sigmets = []
              }
            }
            
          
          Toggle("Satellite", systemImage: mapViewModel.satelliteVisible ? "globe.americas.fill" : "globe.americas", isOn: $mapViewModel.satelliteVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .onChange(of: mapViewModel.satelliteVisible) {
              do {
                try proxyMap?.map?.updateLayer(withId: "satellite", type: RasterLayer.self) { layer in
                  layer.visibility = .constant(mapViewModel.satelliteVisible ? .visible : .none)
                }
              } catch {
                print("Error changing visibility of Map Satellite layer: \(error)")
              }
            }
          
          Toggle("Communications", systemImage: mapViewModel.enrouteCommsVisible ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash", isOn: $mapViewModel.enrouteCommsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          Toggle("Drawing", systemImage: drawingEnabled ? "pencil" : "pencil.slash", isOn: $drawingEnabled)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          Spacer()
            .frame(height: 15)
          
          Toggle("Lg", isOn: $mapViewModel.displayLg)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
          Toggle("Md", isOn: $mapViewModel.displayMd)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
          Toggle("Sm", isOn: $mapViewModel.displaySm)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
          
        }
        .padding([.leading], 5)
        
        /// Bottom-Right VStack of Buttons to control map features
        VStack(spacing: 5) {
          if(mapViewModel.displaySigmet) {
            Button {
              sigmetMenuPopoverVisible.toggle()
            } label: {
              Image(systemName: "hazardsign.fill")
                .font(.title2)
                .foregroundStyle(.mvfr)
            }
            .popover(isPresented: $sigmetMenuPopoverVisible) {
              VStack {
                Text("Sigmet Altitudes")
                RangedSliderView(value: $sigmetSliderRange, bounds: 0...50000,  step: 1000)
              }
              .frame(idealWidth: 250)
              .padding()
              .padding([.leading, .trailing, .bottom], 10)
            }
          }
          
          }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding([.bottom], 100)
        .padding([.trailing], 16)
          
      }
      if (drawingEnabled) {
        // TODO: make this better
        DrawingView(canvas: $canvas)
          .frame(width: 500, height: 1000)
          .background(.ultraThinMaterial)
      }
    }
  }
  
  func getSigmetFillColor(sigmet: String) -> StyleColor {
    switch sigmet {
    case "ICE":
      return .init(.blue)
    case "TURB":
      return .init(.red)
    case "CONVECTIVE":
      return .init(.orange)
    default:
      return .init(.gray)
    }
  }
}

#Preview {
  MapScreen(selectedTab: .constant(.map))
}

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
