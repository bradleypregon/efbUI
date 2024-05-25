//
//  ContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps
import Observation
import PencilKit

@Observable
class MapScreenViewModel {
  var airportJSONModel = AirportJSONModel()
  var largeAirports: [AirportSchema] = []
  var mediumAirports: [AirportSchema] = []
  var smallAirports: [AirportSchema] = []
  
  var displayRadar: Bool = false
  var displayRoute: Bool = false
  var displaySigmet: Bool = false
  var displayLg: Bool = true
  var displayMd: Bool = false
  var displaySm: Bool = false
  var displaySID: Bool = false
  var displaySTAR: Bool = false
  
  var satelliteVisible: Bool = false
  
  init() {
    largeAirports = airportJSONModel.airports.filter { $0.size == .large }
    mediumAirports = airportJSONModel.airports.filter { $0.size == .medium }
    smallAirports = airportJSONModel.airports.filter { $0.size == .small }
  }
}

struct MapScreen: View {
  @Binding var selectedTab: Int
  @Environment(SimConnectShipObserver.self) private var simConnect
//  @Environment(Settings.self) private var settings
  @Environment(SimBriefViewModel.self) private var simbrief
  @Environment(AirportScreenViewModel.self) private var airportVM
  
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  private let style = "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6"
//  @State private var coordinateBounds: CoordinateBounds?
  
  @State private var mapViewModel = MapScreenViewModel()
  
  @State private var selectedAirport: AirportTable?
  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
  @State private var proxyMap: MapProxy? = nil
  @State private var currentZoom: CGFloat = 3.0

  private let radarSourceID = "radar-source"
  @State private var rasterRadarAlertVisible: Bool = false
  
  @State private var drawingEnabled: Bool = false
  @State private var canvas = PKCanvasView()
  
  @State private var waypointPopoverVisible: Bool = false
  let sigmetAPI = SigmetAPI()
  @State private var sigmets: SigmetSchema = []
  @GestureState private var sigmetLongPress = false
  @State private var sigmetMenuPopoverVisible: Bool = false
  @State private var sigmetSliderRange: ClosedRange<Float> = 1000...41000
  
  @State private var mapPopoverSelectedAirport: AirportSchema? = nil
  @State private var mapPopoverSelectedPoint: UnitPoint = .zero
  
  @State private var sidRoute: [[ProcedureTable]] = []
  @State private var starRoute: [[ProcedureTable]] = []
  
  @State var updatingSimConnectShips: Bool = false
  
  var body: some View {
//    let testVisibileAreaPolygonCoords = [
//      CLLocationCoordinate2DMake(coordinateBounds?.northwest.latitude ?? .zero, coordinateBounds?.northwest.longitude ?? .zero),
//      CLLocationCoordinate2DMake(coordinateBounds?.northeast.latitude ?? .zero, coordinateBounds?.northeast.longitude ?? .zero),
//      CLLocationCoordinate2DMake(coordinateBounds?.southeast.latitude ?? .zero, coordinateBounds?.southeast.longitude ?? .zero),
//      CLLocationCoordinate2DMake(coordinateBounds?.southwest.latitude ?? .zero, coordinateBounds?.southwest.longitude ?? .zero),
//    ]
//    let testVisiblePolygon = Polygon([testVisibileAreaPolygonCoords])
    
    NavigationSplitView(columnVisibility: $columnVisibility) {
      // sidebar
      AirportAnnotationSidebarView(selectedTab: $selectedTab, selectedAirport: $selectedAirport)
        .navigationTitle(
          Text(selectedAirport?.airportName ?? "Airport Details")
        )
        .navigationBarTitleDisplayMode(.inline)
    } detail: {
      // map
      ZStack {
        GeometryReader { geometry in
          MapReader { proxy in
            Map(viewport: $viewport) {
              // MARK: Testing Polygon for map bounds
              //            PolygonAnnotation(polygon: testVisiblePolygon)
              //              .fillColor(StyleColor(UIColor.blue))
              //              .fillOpacity(0.1)
              
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
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                      columnVisibility = .all
                    }
                    .onLongPressGesture { context in
                      mapPopoverSelectedAirport = airport
                      let point = context.point
                      mapPopoverSelectedPoint = UnitPoint(x: (point.x / geometry.size.width), y: (point.y / geometry.size.height))
                      return true
                    }
                }
              }
              
              
              // MARK: Medium Airports
              if mapViewModel.displayMd {
                PointAnnotationGroup(mapViewModel.mediumAirports, id: \.id) { airport in
                  PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.lat, longitude: airport.long), isDraggable: false)
                    .image(named: "md-airport-vfr")
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                      columnVisibility = .all
                    }
                    .textField(airport.icao)
                    .textOffset(x: 0.0, y: -1.9)
                    .textColor(.white)
                    .textSize(11)
                }
                .clusterOptions(ClusterOptions(clusterRadius: 75.0, clusterMaxZoom: 8.0))
              }
              
              
              // MARK: Small Airports
              if mapViewModel.displaySm {
                PointAnnotationGroup(mapViewModel.smallAirports) { airport in
                  PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.lat, longitude: airport.long), isDraggable: false)
                    .image(named: "sm-airport-vfr")
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(airport.icao)
                      columnVisibility = .all
                    }
                    .textField(airport.icao)
                    .textOffset(x: 0.0, y: -1.9)
                    .textColor(.white)
                    .textSize(9)
                }
                .clusterOptions(ClusterOptions(circleRadius: .constant(12.0), clusterRadius: 75.0, clusterMaxZoom: 6.5))
              }
              
              // MARK: Annotations that receive updates (ownship and traffic)
              
              // MARK: Ownship Annotation
//              if simConnect.ownship.coordinate.latitude != .zero {
//                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: simConnect.ownship.coordinate.latitude, longitude: simConnect.ownship.coordinate.longitude)) {
//                  VStack(spacing: 0) {
//                    Image("ShipArrow")
//                      .rotationEffect(.degrees(simConnect.ownship.heading))
//                    Text(simbrief.ofp?.aircraft.reg ?? "ownship")
//                      .font(.caption)
//                      .foregroundStyle(.white)
//                  }
//                }
//              }
              
              // MARK: Traffic Annotations
//              ForEvery(simConnect.traffic, id: \.id) { traffic in
//                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: traffic.coordinate.latitude, longitude: traffic.coordinate.longitude)) {
//                  VStack(spacing: 0) {
//                    if displayTrafficAltitude {
//                      Text("\(traffic.altitude.string)'")
//                        .font(.system(size: 9))
//                        .foregroundStyle(.lifr)
//                    }
//                    Image("TrafficArrow")
//                      .rotationEffect(.degrees(traffic.heading))
//                    Text(traffic.registration ?? "tfc")
//                      .font(.system(size: 9))
//                      .foregroundStyle(.lifr)
//                  }
//                }
//                .allowOverlap(true)
//              }
              
              // MARK: Route Display
              if mapViewModel.displayRoute {
                if let navlog = simbrief.ofp?.navlog {
                  PolylineAnnotationGroup {
                    PolylineAnnotation(lineCoordinates: navlog.map { CLLocationCoordinate2D(latitude: Double($0.lat) ?? .zero, longitude: Double($0.long) ?? .zero)})
                      .lineWidth(2)
                      .lineColor(.blue)
                  }
                  ForEvery(navlog.filter { $0.type != "apt" }, id:\.id) { wpt in
                    MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(wpt.lat) ?? .zero, longitude: Double(wpt.long) ?? .zero)) {
                      MapScreenWaypointView(wpt: wpt)
                    }
                    .allowOverlap(wpt.ident == "TOC" || wpt.ident == "TOD" ? true : false)
                    .ignoreCameraPadding(true)
                  }
                }
              }
              
              // MARK: Sigmet Data
              // CONVECTIVE: orange, IFR: blue, MTN OBSCN: gray, TURB: red
              if mapViewModel.displaySigmet {
                PolygonAnnotationGroup(sigmets.filter { !$0.coords.isEmpty }, id: \.airSigmetId) { sigmet in
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
              
              //MARK: SID Chart
              if mapViewModel.displaySID {
                // Currently, waypoints for each runway on the sid are showing up
                // Filter by 'EE'? Essential and End of Enroute??
                //  - need to be careful though, as SID can have > 1 "ending" waypoint
                PolylineAnnotationGroup(sidRoute.compactMap { $0 }, id: \.self) { route in
                  PolylineAnnotation(lineCoordinates: route.map { CLLocationCoordinate2D(latitude: $0.waypointLatitude, longitude: $0.waypointLongitude)}.filter { $0.latitude != .zero && $0.longitude != .zero })
                    .lineWidth(2.0)
                    .lineColor(StyleColor( UIColor(red: .random(in: 0.0...1.0), green: .random(in: 0.0...1.0), blue: .random(in: 0.0...1.0), alpha: 1.0) ))
                    .onTapGesture {
                      // TODO: popover with route details?
                      print(route.first?.procedureIdentifier)
                    }
                }
              }
              
              // MARK: STAR Chart
              if mapViewModel.displaySTAR {
                PolylineAnnotationGroup(starRoute.compactMap {$0}, id: \.self) { route in
                  PolylineAnnotation(lineCoordinates: route.map { CLLocationCoordinate2D(latitude: $0.waypointLatitude, longitude: $0.waypointLongitude)}.filter { $0.latitude != .zero && $0.longitude != .zero})
                    .lineWidth(3.0)
                    .lineColor(StyleColor( UIColor(red: .random(in: 0.0...1.0), green: .random(in: 0.0...1.0), blue: .random(in: 0.0...1.0), alpha: 1.0) ))
                    .onTapGesture {
                      print(route.first?.procedureIdentifier)
                    }
                }
              }
            }
            .mapStyle(.init(uri: StyleURI(rawValue: style) ?? StyleURI.dark))
            .ornamentOptions(ornamentOptions)
            .onStyleLoaded { _ in
              do {
                try proxy.map?.addImage(UIImage(named: "ShipArrow") ?? UIImage(), id: "ShipArrow")
                try proxy.map?.addImage(UIImage(named: "TrafficArrow") ?? UIImage(), id: "TrafficArrow")
              } catch {
                print("Error adding image to map: \(error)")
              }
              
            }
            // TODO: Follow Mapbox recommendation for .onCameraChanged
            // NO @State variable changes. Too much computation and redraws
//            .onCameraChanged(action: { changed in
//              currentZoom = changed.cameraState.zoom
//              coordinateBounds = calculateVisibleMapRegion(center: changed.cameraState.center, zoom: changed.cameraState.zoom, geometry: geometry)
//              if let coordinateBounds {
//                handleCameraChange(zoom: changed.cameraState.zoom, bounds: coordinateBounds)
//              }
//            })
            .onAppear {
              proxyMap = proxy
              if ServerStatus.shared.status == .running {
                addOwnshipLayer()
              }
              if airportVM.requestMap {
                Task {
                  guard let temp = airportVM.selectedAirport else { return }
                  proxy.camera?.ease(to: CameraOptions(center: CLLocationCoordinate2DMake(temp.airportRefLat, temp.airportRefLong), zoom: 13), duration: 2)
                  airportVM.requestMap = false
                }
                
              }
            }
            .alert("Radar Error", isPresented: $rasterRadarAlertVisible) {
              Button("Ok") {
                // TODO: Handle retrying radar
                mapViewModel.displayRadar.toggle()
              }
            }
            .popover(item: $mapPopoverSelectedAirport, attachmentAnchor: PopoverAttachmentAnchor.point(mapPopoverSelectedPoint)) { airport in
              let sids = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_sids")
              let stars = SQLiteManager.shared.getAirportProcedures(airport.icao, procedure: "tbl_stars")
              
              VStack {
                Text(airport.name)
                
                Button {
                  print("View Airport")
                } label: {
                  Text("View Airport")
                }
                
                // TODO: Fix .toggle() causing routes to not show up
                Menu("View Procedures") {
                  if (!sids.isEmpty) {
                    Button {
                      let grouped = Dictionary(grouping: sids, by: { $0.procedureIdentifier })
                      self.sidRoute = Array(grouped.values)
                      mapViewModel.displaySID.toggle()
                    } label: {
                      Text("View SIDs")
                    }
                  }
                  
                  if (!stars.isEmpty) {
                    Button {
                      let grouped = Dictionary(grouping: stars, by: {$0.procedureIdentifier })
                      self.starRoute = Array(grouped.values)
                      mapViewModel.displaySID.toggle()
                    } label: {
                      Text("View STARs")
                    }
                  }
                  
                }
              }
              .frame(idealWidth: 150, idealHeight: 150)
              
            }
          }
          .ignoresSafeArea()
          .onChange(of: ServerStatus.shared.status) {
            if ServerStatus.shared.status == .running {
              addOwnshipLayer()
            }
          }
          
          // MARK: Menu
          VStack(spacing: 5) {
            Toggle("Radar", systemImage: mapViewModel.displayRadar ? "cloud.sun.fill" : "cloud.sun", isOn: $mapViewModel.displayRadar)
              .font(.title2)
              .tint(.mvfr)
              .toggleStyle(.button)
              .labelStyle(.iconOnly)
              .contentTransition(.symbolEffect)
              .onChange(of: mapViewModel.displayRadar) {
                mapViewModel.displayRadar ? addRasterRadarSource() : removeRasterRadarSource()
              }
            
            Toggle("Route", systemImage: mapViewModel.displayRoute ? "point.topleft.down.to.point.bottomright.curvepath.fill" : "point.topleft.down.to.point.bottomright.curvepath", isOn: $mapViewModel.displayRoute)
              .font(.title2)
              .tint(.mvfr)
              .toggleStyle(.button)
              .labelStyle(.iconOnly)
              .contentTransition(.symbolEffect)
            
            // TODO: Fix long press gesture not working properly
            Toggle("Sigmet", systemImage: mapViewModel.displaySigmet ? "hazardsign.fill" : "hazardsign", isOn: $mapViewModel.displaySigmet)
              .font(.title2)
              .tint(.mvfr)
              .toggleStyle(.button)
              .labelStyle(.iconOnly)
              .contentTransition(.symbolEffect)
              .onChange(of: mapViewModel.displaySigmet) {
                // TODO: stash fetch as to not call api every time is tapped
                sigmetAPI.fetchSigmet { sigmets in
                  self.sigmets = sigmets
                }
              }
              .onLongPressGesture {
                sigmetMenuPopoverVisible.toggle()
              }
              .popover(isPresented: $sigmetMenuPopoverVisible) {
                VStack {
                  Text("Sigmet Altitudes")
                  RangedSliderView(value: $sigmetSliderRange, bounds: 0...50000,  step: 1000)
                }
                .frame(idealWidth: 250)
                .padding()
                .padding([.leading, .trailing, .bottom], 20)
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
        }
        if (drawingEnabled) {
          // TODO: make this better
          DrawingView(canvas: $canvas)
            .frame(width: 500, height: 1000)
            .allowsHitTesting(true)
        }
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
  
  func addOwnshipLayer() {
    do {
      var layer = LocationIndicatorLayer(id: "OwnshipLayer")
      layer.topImage = .constant(ResolvedImage.name("ShipArrow"))
      
      try proxyMap?.map?.addLayer(layer)
      updatingSimConnectShips = true
      updateOwnshipLayer()
    } catch {
      print("Error adding ownship layer: \(error)")
    }
  }
  
  func updateOwnshipLayer() {
    if updatingSimConnectShips {
      _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        do {
          try proxyMap?.map?.updateLayer(withId: "OwnshipLayer", type: LocationIndicatorLayer.self) { layer in
            layer.location = .constant([simConnect.ownship.coordinate.latitude, simConnect.ownship.coordinate.longitude, simConnect.ownship.altitude])
            layer.bearing = .constant(simConnect.ownship.heading)
          }
        } catch let e {
          print("Error updating ownship layer: \(e)")
        }
      }
    }
  }
  
  // MARK: addRasterRadarSource
  func addRasterRadarSource() {
    // https://api.rainviewer.com/public/weather-maps.json
    /// image/mapsize/stringpaths (x,y,z)/mapcolor/options(smooth_snow)/filetype
    // TODO: Get current Radar API json string
    let rainviewer = RainviewerAPI()
    
    rainviewer.fetchRadar { radar in
      let jsonPath = radar.radar?.nowcast?.first?.path ?? ""
      
      let stringPaths = "{z}/{x}/{y}"
      let mapColor = "4"
      let options = "1_1" // smooth_snow
      
      let url = String("https://tilecache.rainviewer.com\(jsonPath)/512/\(stringPaths)/\(mapColor)/\(options).png")
      
      var rasterSource = RasterSource(id: radarSourceID)
      rasterSource.tiles = [url]
      rasterSource.tileSize = 512
      
      var rasterLayer = RasterLayer(id: "radar-layer", source: rasterSource.id)
      rasterLayer.rasterOpacity = .constant(0.4)
      
      do {
        try proxyMap?.map?.addSource(rasterSource)
        try proxyMap?.map?.addLayer(rasterLayer)
      } catch {
        rasterRadarAlertVisible = true
        print("Failed to update style. Error: \(error)")
      }
    }
    
  }
  
  
  
  // MARK: removeRasterRadarSource
  func removeRasterRadarSource() {
    do {
      try proxyMap?.map?.removeLayer(withId: "radar-layer")
      try proxyMap?.map?.removeSource(withId: radarSourceID)
    } catch {
      print("Failed to remove radar source. Error: \(error)")
    }
  }
  
  // MARK: handleCameraChange
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

struct MapScreenWaypointView: View {
  @State private var popoverPresented: Bool = false
  var wpt: OFPNavlog
  
  var body: some View {
    Button {
      popoverPresented.toggle()
    } label: {
      VStack {
        Image(systemName: wpt.ident == "TOC" || wpt.ident == "TOD" ? "bolt.horizontal.fill" : "triangle.fill")
          .foregroundStyle(wpt.ident == "TOC" || wpt.ident == "TOD" ? .green : .blue)
        Text(wpt.ident)
          .padding(6)
          .background(.blue)
          .foregroundStyle(.white)
          .clipShape(Capsule())
          .font(.caption)
      }
    }
    .popover(isPresented: $popoverPresented) {
      List {
        Text("Ident: \(wpt.ident)")
        Text("Name: \(wpt.name)")
        Text("Type: \(wpt.type)")
        Text("Freq: \(wpt.frequency)")
        Text("Via: \(wpt.via)")
        Text("Alt: \(wpt.altitude)")
        Text("W/C: \(wpt.windComponent)")
        Text("Time leg: \(wpt.timeLeg)")
        Text("Time Total: \(wpt.timeTotal)")
        Text("Fuel Leg: \(wpt.fuelLeg)")
        Text("Fuel Total: \(wpt.fuelTotalUsed)")
        Text("Wind: \(wpt.windDir)/\(wpt.windSpd)")
        Text("Shear: \(wpt.shear)")
      }
      .font(.caption)
      .listStyle(.plain)
      .background(.bar)
      .frame(idealWidth: 200, idealHeight: 400)
    }
  }
}

#Preview {
  MapScreen(selectedTab: .constant(1))
}
