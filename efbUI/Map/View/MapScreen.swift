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
  
  init() {
    largeAirports = airportJSONModel.airports.filter { $0.size == .large }
    mediumAirports = airportJSONModel.airports.filter { $0.size == .medium }
    smallAirports = airportJSONModel.airports.filter { $0.size == .small }
  }
}

struct MapScreen: View {
  @Binding var selectedTab: Int
  @Environment(SimConnectShipObserver.self) private var simConnect
  @Environment(Settings.self) private var settings
  @Environment(SimBriefViewModel.self) private var simbrief
  @Environment(AirportDetailViewModel.self) private var airportVM
  
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  private let style = "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6"
//  @State private var coordinateBounds: CoordinateBounds?
  
  @State private var mapViewModel = MapScreenViewModel()
  
  @State private var selectedAirport: AirportTable?
  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
  @State private var proxyMap: MapProxy? = nil
  @State private var currentZoom: CGFloat = 3.0
  
  var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  private let radarSourceID = "radar-source"
  @State private var rasterRadarAlertVisible: Bool = false
  @State private var displayTrafficAltitude: Bool = true
  
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
                    .textOffset([0.0, -1.8])
                    .textColor(StyleColor(.white))
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
                    .textOffset([0.0, -1.6])
                    .textColor(StyleColor(.white))
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
                }
                .clusterOptions(ClusterOptions(circleRadius: .constant(25.0), clusterMaxZoom: 8.0))
              }
              
              
              // MARK: Ownship Annotation
              if simConnect.ownship.coordinate.latitude != .zero {
                PointAnnotation(coordinate: CLLocationCoordinate2DMake(simConnect.ownship.coordinate.latitude, simConnect.ownship.coordinate.longitude), isSelected: false, isDraggable: false)
                  .image(named: "ShipArrow")
                  .iconRotate(simConnect.ownship.heading)
                  .textField(simbrief.ofp?.aircraft.reg ?? "ownship")
                  .textOffset([0, 1.7])
                  .textColor(StyleColor(.white))
                  .textSize(12)
              }
              
              // MARK: Traffic Annotations
              ForEvery(simConnect.traffic, id: \.id) { traffic in
                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: traffic.coordinate.latitude, longitude: traffic.coordinate.longitude)) {
                  VStack(spacing: 0) {
                    if displayTrafficAltitude {
                      Text("\(traffic.altitude.string)'")
                        .font(.system(size: 9))
                        .foregroundStyle(.lifr)
                    }
                    Image("TrafficArrow")
                      .rotationEffect(.degrees(traffic.heading))
                    Text(traffic.registration ?? "tfc")
                      .font(.system(size: 9))
                      .foregroundStyle(.lifr)
                  }
                }
                .allowOverlap(true)
              }
              
              // MARK: Route Display
              if mapViewModel.displayRoute {
                if let navlog = simbrief.ofp?.navlog {
                  PolylineAnnotationGroup {
                    PolylineAnnotation(lineCoordinates: navlog.map { CLLocationCoordinate2D(latitude: Double($0.lat) ?? .zero, longitude: Double($0.long) ?? .zero)})
                      .lineWidth(2)
                      .lineColor(StyleColor(.blue))
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
                    .fillColor(sigmet.hazard == "ICE" ? StyleColor(.blue) : sigmet.hazard == "TURB" ? StyleColor(.red) : sigmet.hazard == "CONVECTIVE" ? StyleColor(.orange) : StyleColor(.gray))
                    .fillOutlineColor(StyleColor(.black))
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
              
              
              // TODO: Filter waypoints. Too many are showing up, just want the route
              // TODO: Have text label at end of route
              // TODO: Fix multiple routes overlapping each other
              
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
          .ignoresSafeArea(.all)
          
          // MARK: Menu
          VStack(spacing: 5) {
            Toggle("Radar", systemImage: mapViewModel.displayRadar ? "cloud.sun.fill" : "cloud.sun", isOn: $mapViewModel.displayRadar)
              .font(.title2)
              .tint(.mvfr)
              .toggleStyle(.button)
              .labelStyle(.iconOnly)
              .contentTransition(.symbolEffect)
              .onChange(of: mapViewModel.displayRadar) {
                if let proxyMap, let map = proxyMap.map {
                  mapViewModel.displayRadar ? addRasterRadarSource(map) : removeRasterRadarSource(map)
                }
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
//              .gesture(
//                LongPressGesture(minimumDuration: 0.25)
//                  .updating($sigmetLongPress) { currentState, gestureState, transaction in
//                    gestureState = currentState
//                  }
//                  .onEnded { _ in
//                    sigmetMenuPopoverVisible.toggle()
//                  }
//              )
              .popover(isPresented: $sigmetMenuPopoverVisible) {
                VStack {
                  Text("Sigmet Altitudes")
                  RangedSliderView(value: $sigmetSliderRange, bounds: 0...50000,  step: 1000)
                }
                .frame(idealWidth: 250)
                .padding()
                .padding([.leading, .trailing, .bottom], 20)
              }
            
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
          DrawingView(canvas: $canvas)
            .allowsHitTesting(false)
        }
      }
    }
    
  }
  
  // MARK: updateImageRotation
  func updateImageRotation(for image: String, to heading: Double, size: CGFloat) {
//    _ = ownshipImage?.rotationEffect(.degrees(heading))
//    DispatchQueue.main.async {
      
//      if let img = UIImage(named: image), let rotated = img.rotate(angle: .degrees(heading)) {
//        ownshipImage.rotation
//      }
//      let img = UIImage(named: image)
//      if let resized = img?.resize(newWidth: size), let rotatedImg = resized.rotate(angle: .degrees(heading)) {
//        ownshipImage = Image(uiImage: rotatedImg)
//      } else {
//        if let img {
//          ownshipImage = Image(uiImage: img)
//        }
//      }
//    }
  }
  
  // MARK: addRasterRadarSource
  func addRasterRadarSource(_ map: MapboxMap) {
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
        try map.addSource(rasterSource)
        try map.addLayer(rasterLayer)
      } catch {
        rasterRadarAlertVisible = true
        print("Failed to update style. Error: \(error)")
      }
    }
    
  }
  
  
  
  // MARK: removeRasterRadarSource
  func removeRasterRadarSource(_ map: MapboxMap) {
    
    do {
      try map.removeLayer(withId: "radar-layer")
      try map.removeSource(withId: radarSourceID)
    } catch {
      print("Failed to remove radar source. Error: \(error)")
    }
  }
  
  // MARK: getAirportIcon
  func getAirportIcon(for size: String) -> PointAnnotation.Image? {
    switch size {
    case "Large":
      if let temp = UIImage(named: "lg-airport-default"), let resized = temp.resize(newWidth: 42) {
        return PointAnnotation.Image(image: resized, name: "lg")
      }
    case "Medium":
      if let temp = UIImage(named: "md-airport-default"), let resized = temp.resize(newWidth: 38) {
        return PointAnnotation.Image(image: resized, name: "md")
      }
    default:
      if let temp = UIImage(named: "sm-airport-default"), let resized = temp.resize(newWidth: 32) {
        return PointAnnotation.Image(image: resized, name: "sm")
      }
    }
    
    if let temp = UIImage(named: "sm-airport-default"), let resized = temp.resize(newWidth: 32) {
      return PointAnnotation.Image(image: resized, name: "sm")
    }
    return nil
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
  
  // MARK: removeAirports
  func removeAirports(size: String) {
//    airports.removeAll(where: { $0.properties.size.rawValue == size })
    
//    for airport in airportJSONModel.airports {
//      if airport.properties.size.rawValue == size {
//        airport.visible = false
//      }
//    }
  }
  
  // MARK: loadAirports
  func loadAirports(bounds: CoordinateBounds, size: String) {
//    let prevVisibleAirports = cacheAirports
//    let visibleAirports = airportJSONModel.fetchGeoJSON(size: size, bounds: bounds)
//    cacheAirports = visibleAirports
//    
//    let removedAirports = prevVisibleAirports.filter { !visibleAirports.contains($0) }
//    let addedAirports = visibleAirports.filter { !prevVisibleAirports.contains($0) }
//
//    airports.removeAll(where: { removedAirports.contains($0) })
//    airports.append(contentsOf: addedAirports)
//    airportJSONModel.fetchVisibleAirports(size: size, bounds: bounds)
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
