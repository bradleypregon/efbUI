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
  @Environment(SimConnectShipObserver.self) var simConnect
//  @Environment(Settings.self) private var settings
  @Environment(AirportScreenViewModel.self) private var airportVM
  @Environment(RouteManager.self) private var routeManager
  
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  private let style = "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6"
  
  @State var mapViewModel = MapScreenViewModel()
  
  @State var selectedAirport: AirportTable?
  @State var proxyMap: MapProxy? = nil
  @State var currentZoom: CGFloat = 3.0

  @State var rasterRadarAlertVisible: Bool = false
  
  @State var drawingEnabled: Bool = false
  @State var canvas = PKCanvasView()
  
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
            
            /*
            RasterSource(id: "VFR-Sectional")
              .tiles(["https://tiles.arcgis.com/tiles/ssFJjBXIUyZDrSYZ/arcgis/rest/services/VFR_Sectional/MapServer/tile/{z}/{y}/{x}.png"])
              
            RasterLayer(id: "VFR-Sectional-Layer", source: "VFR-Sectional")
            */
            
            
            if mapViewModel.displayLg {
              PointAnnotationGroup(mapViewModel.largeAirports) { airport in
                PointAnnotation(coordinate: CLLocationCoordinate2DMake(airport.lat, airport.long), isDraggable: false)
                  .image(named: "lg-airport-vfr")
                  .textField(airport.icao)
                  .textOffset(x: 0.0, y: -1.8)
                  .textColor(.white)
                  .textSize(12)
                  .onTapGesture { context in
                    // get departures and arrivals
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
                .textOffset(x: 0, y: 2)
                .textSize(7)
                .textColor(.white)
                .textFont(["Roboto Bold Condensed"])
              SymbolLayer(id: "TrafficAltLayerID", source: "TrafficTextID")
                .textField(Exp(.get) { "alt" })
                .textSize(7)
                .textOffset(x: 0, y: -2)
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
              try proxy.map?.addImage(UIImage(named: "lg-airport-vfr") ?? UIImage(), id: "LgAirportVFR")
              try proxy.map?.addImage(UIImage(named: "TrafficArrow") ?? UIImage(), id: "TrafficArrow")
              addOwnshipLayer()
            } catch {
              print("Error adding image to map: \(error)")
            }
          }
          .onCameraChanged { context in
            if context.cameraState.zoom >= 6 {
              // remove
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
        }
        .ignoresSafeArea()
        .overlay {
          if drawingEnabled {
            VStack {
              Spacer()
              DrawingView(canvas: $canvas)
                .frame(width: geometry.size.width, height: (geometry.size.height * 0.3), alignment: .bottom)
                .background(.ultraThinMaterial)
            }
            
          }
        }
        
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
            .onChange(of: mapViewModel.displayLg) {
              do {
                guard let map = proxyMap?.map else { return }
                var layer = try map.layer(withId: Id.lgAirports)
                layer.visibility = mapViewModel.displayLg ? .constant(.visible) : .constant(.none)
              } catch {
                print("Error changing visiblity of large airports")
              }
            }
          Toggle("Md", isOn: $mapViewModel.displayMd)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .onChange(of: mapViewModel.displayMd) {
              do {
                guard let map = proxyMap?.map else { return }
                var layer = try map.layer(withId: Id.mdAirports)
                layer.visibility = mapViewModel.displayMd ? .constant(.visible) : .constant(.none)
              } catch {
                print("Error changing visiblity of medium airports")
              }
            }
          Toggle("Sm", isOn: $mapViewModel.displaySm)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .onChange(of: mapViewModel.displaySm) {
              do {
                guard var layer = try proxyMap?.map?.layer(withId: Id.smAirports) else {
                  print("Error getting airport layer")
                  return
                }
                layer.visibility = mapViewModel.displaySm ? .constant(.visible) : .constant(.none)
              } catch {
                print("Error changing visiblity of small airports")
              }
            }
          
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
  
  func setupAirportClusterLayer() async throws {
//    let image = UIImage(named: Id.airportIcon)?.resize(newWidth: 28)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    let image = UIImage(named: Id.airportIcon) ?? UIImage()
    
    guard let map = proxyMap?.map else {
      print("error with proxy map")
      return
    }
    
    do {
//      try map.addImage(image, id: Id.airportIcon, sdf: true)
      try map.addImage(image, id: Id.airportIcon)
    } catch {
      print("error adding AirportIcon to map: \(error)")
    }
    
    guard let url = Bundle.main.url(forResource: "Airports", withExtension: "geojson") else {
      print("error with url")
      return
    }
    
    var source = GeoJSONSource(id: Id.source)
    source.data = .url(url)
    
//    source.cluster = true
//    source.clusterRadius = 75
    
//    let clusteredLayer = createClusteredLayer()
//    let unclusteredLayer = createUnclusteredLayer()
//    let clusterCountLayer = createClusterCountLayer()
    
    var lg = SymbolLayer(id: Id.lgAirports, source: Id.source)
    lg.filter = Exp(.eq) { Exp(.get) { "size" }; "Large" }
    lg.iconImage = .constant(.name(Id.airportIcon))
    lg.textField = .expression(Exp(.get) { "icao" })
    lg.textSize = .constant(12)
    lg.textOffset = .constant([0, -1.8])
    lg.textColor = .constant(StyleColor(.white))
    lg.visibility = .constant(.visible)
    
    var md = SymbolLayer(id: Id.mdAirports, source: Id.source)
    md.filter = Exp(.eq) { Exp(.get) { "size" }; "Medium" }
    md.iconImage = .constant(.name(Id.airportIcon))
    md.textField = .expression(Exp(.get) { "icao" })
    md.textSize = .constant(12)
    md.textOffset = .constant([0, -1.8])
    md.textColor = .constant(StyleColor(.white))
    md.visibility = .constant(.none)
    
    var sm = SymbolLayer(id: Id.smAirports, source: Id.source)
    sm.filter = Exp(.eq) { Exp(.get) { "size" }; "Small" }
    sm.iconImage = .constant(.name(Id.airportIcon))
    sm.textField = .expression(Exp(.get) { "icao" })
    sm.textSize = .constant(12)
    sm.textOffset = .constant([0, -1.8])
    sm.textColor = .constant(StyleColor(.white))
    sm.visibility = .constant(.none)
    
    
    try map.addSource(source)
    try map.addLayer(lg)
    try map.addLayer(md)
    try map.addLayer(sm)
//    try map.addLayer(clusteredLayer)
//    try map.addLayer(unclusteredLayer)
//    try map.addLayer(clusterCountLayer)
  }
  
  /*
  func createClusteredLayer() -> CircleLayer {
    var clusteredLayer = CircleLayer(id: Id.clusterCircle, source: Id.source)
    clusteredLayer.filter = Exp(.all) {
      Exp(.has) { "point_count" }
      Exp(.gt) {
        Exp(.get) { "sm_md_count" }
        0
      }
    }
    clusteredLayer.filter = Exp(.has) { "point_count" }
    
    clusteredLayer.circleColor = .constant(StyleColor(.mvfr))
    clusteredLayer.circleRadius = .constant(16)
    return clusteredLayer
  }
  
  func createUnclusteredLayer() -> SymbolLayer {
    var layer = SymbolLayer(id: Id.point, source: Id.source)
    layer.filter = Exp(.not) {
      Exp(.has) { "point_count" }
    }
    
    layer.iconImage = .constant(.name(Id.airportIcon))
//    layer.iconColor = .constant(StyleColor(UIColor.vfr))
    layer.textField = .expression(Exp(.get) { "icao" })
    layer.textSize = .constant(12)
    layer.textOffset = .constant([0, -1.8])
    layer.textColor = .constant(StyleColor(.white))
    
    return layer
  }
  
  func createClusterCountLayer() -> SymbolLayer {
    var numLayer = SymbolLayer(id: Id.count, source: Id.source)
    numLayer.filter = Exp(.has) { "point_count" }
    
    numLayer.textField = .expression(Exp(.get) { "point_count" })
    numLayer.textSize = .constant(12)
    
    return numLayer
  }
  */
}

private enum Id {
//  static let clusterCircle = "AirportClusterCirleLayer"
//  static let point = "AirportUnclusteredSymbolLayer"
//  static let count = "AirportClusterCountLayer"
  static let source = "AirportsSource"
  static let airportIcon = "lg-airport-vfr"
  static let lgAirports = "LargeAirportsLayer"
  static let mdAirports = "MediumAirportsLayer"
  static let smAirports = "SmallAirportsLayer"
}

#Preview {
  MapScreen(selectedTab: .constant(.map))
}
