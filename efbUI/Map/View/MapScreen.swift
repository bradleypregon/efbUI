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
  
  var largeAirports: [Airport] = []
  var mediumAirports: [Airport] = []
  var smallAirports: [Airport] = []
  
  init() {
    largeAirports = airportJSONModel.airports.filter { $0.properties.size.rawValue == "Large" }
    mediumAirports = airportJSONModel.airports.filter { $0.properties.size.rawValue == "Medium" }
    smallAirports = airportJSONModel.airports.filter { $0.properties.size.rawValue == "Small" }
  }
  
  func fetchLargeAirports(bounds: CoordinateBounds) {
    for airport in largeAirports {
      if !airport.visible && bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = true
      } else if airport.visible && !bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = false
      }
    }
  }
  
  func fetchMediumAirports(bounds: CoordinateBounds) {
    for airport in mediumAirports {
      if !airport.visible && bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = true
      } else if airport.visible && !bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = false
      }
    }
  }
  
  func fetchSmallAirports(bounds: CoordinateBounds) {
    for airport in smallAirports {
      if !airport.visible && bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = true
      } else if airport.visible && !bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
        airport.visible = false
      }
    }
  }
  
  func hideLargeAirports() {
    for airport in largeAirports {
      if airport.visible {
        airport.visible = false
      }
    }
  }
  
  func hideMediumAirports() {
    for airport in mediumAirports {
      if airport.visible {
        airport.visible = false
      }
    }
  }
  
  func hideSmallAirports() {
    for airport in smallAirports {
      if airport.visible {
        airport.visible = false
      }
    }
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
  @State private var coordinateBounds: CoordinateBounds?
  
//  var airportJSONModel = AirportJSONModel()
  @State private var mapViewModel = MapScreenViewModel()
  
  @State private var selectedAirport: AirportTable?
  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
  @State private var proxyMap: MapProxy? = nil
  @State private var currentZoom: CGFloat = 3.0
  
  @State private var largeAnnotationsVisible: Bool = true
  @State private var mediumAnnotationsVisible: Bool = false
  @State private var smallAnnotationsVisible: Bool = false
  @State private var routeVisible: Bool = false
  
  @State private var displayRadar: Bool = false {
    didSet {
      if let proxyMap, let map = proxyMap.map {
        displayRadar ? addRasterRadarSource(map) : removeRasterRadarSource(map)
      }
    }
  }
  var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
//  @State var ownshipImage: Image = Image("ShipArrow32")
  
  private let radarSourceID = "radar-source"
  @State private var rasterRadarAlertVisible: Bool = false
  @State private var displayTrafficAltitude: Bool = true
  
  @State private var drawingEnabled: Bool = false
  @State private var canvas = PKCanvasView()
  
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
              if largeAnnotationsVisible {
                PointAnnotationGroup(mapViewModel.largeAirports) { airport in
                  PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), isDraggable: false)
                    .image(PointAnnotation.Image(image: UIImage(named: "lg-airport-default42") ?? UIImage(), name: "lg"))
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(airport.properties.icao)
                      columnVisibility = .all
                    }
                    .textField(airport.properties.icao)
                    .textOffset([0.0, -1.6])
                    .textColor(StyleColor(.white))
                    .textHaloWidth(3)
                    .textHaloColor(StyleColor(.black))
                    .textSize(14)
                }
              }
              
              
              // MARK: Medium Airports
              if mediumAnnotationsVisible {
                PointAnnotationGroup(mapViewModel.mediumAirports, id: \.id) { airport in
                  PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), isDraggable: false)
                    .image(PointAnnotation.Image(image: UIImage(named: "md-airport-default40") ?? UIImage(), name: "md"))
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(airport.properties.icao)
                      columnVisibility = .all
                    }
                    .textField(airport.properties.icao)
                    .textOffset([0.0, -1.6])
                    .textColor(StyleColor(.white))
                    .textHaloBlur(10)
                    .textHaloWidth(10)
                    .textHaloColor(StyleColor(.black))
                    .textSize(11)
                }
                .clusterOptions(ClusterOptions(clusterRadius: 75.0, clusterMaxZoom: 8.0))
              }
              
              
              // MARK: Small Airports
              if smallAnnotationsVisible {
                PointAnnotationGroup(mapViewModel.smallAirports) { smallAirport in
                  PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: smallAirport.coordinates.lat, longitude: smallAirport.coordinates.long), isDraggable: false)
                    .image(PointAnnotation.Image(image: UIImage(named: "sm-airport-default38") ?? UIImage(), name: "sm"))
                    .onTapGesture {
                      selectedAirport = SQLiteManager.shared.selectAirport(smallAirport.properties.icao)
                      columnVisibility = .all
                    }
                }
                .clusterOptions(ClusterOptions(circleRadius: .constant(25.0), clusterMaxZoom: 8.0))
              }
              
              
              // MARK: Ownship Annotation
              MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: simConnect.ship?.coordinate.latitude ?? .zero, longitude: simConnect.ship?.coordinate.longitude ?? .zero)) {
                VStack(spacing: 0) {
                  Image("ShipArrow")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(simConnect.ship?.heading ?? .zero))
                  Text((simbrief.ofp?.aircraft.reg) ?? "ownship")
                    .font(.system(size: 10))
                    .foregroundStyle(.teal)
                    .glowBorder(color: .black, lineWidth: 4)
                }
              }
              .allowOverlap(true)
              
              // MARK: Traffic Annotations
              ForEvery(simConnect.simConnectTraffic, id: \.id) { traffic in
                MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: traffic.coordinate.latitude, longitude: traffic.coordinate.longitude)) {
                  VStack(spacing: 0) {
                    if displayTrafficAltitude {
                      Text(traffic.altitude.string)
                        .font(.system(size: 9))
                        .glowBorder(color: .black, lineWidth: 4)
                        .foregroundStyle(.pink)
                    }
                    Image("TrafficArrow")
                      .resizable()
                      .frame(width: 30, height: 30)
                      .rotationEffect(.degrees(traffic.heading))
                    Text(traffic.registration ?? "Tfc")
                      .font(.system(size: 9))
                      .glowBorder(color: .black, lineWidth: 4)
                      .foregroundStyle(.pink)
                  }
                }
                .allowOverlap(true)
              }
              
              // MARK: Route Display
              if routeVisible {
                if let navlog = simbrief.ofp?.navlog {
                  PolylineAnnotationGroup {
                    PolylineAnnotation(lineCoordinates: navlog.map { CLLocationCoordinate2D(latitude: Double($0.lat) ?? .zero, longitude: Double($0.long) ?? .zero)})
                      .lineWidth(2)
                      .lineColor(StyleColor(.blue))
                  }
                  ForEvery(navlog.filter { $0.type != "apt" }, id:\.id) { wpt in
                    MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(wpt.lat) ?? .zero, longitude: Double(wpt.long) ?? .zero)) {
                      Button {
                        print(wpt.ident)
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
                      
                    }
                    .allowOverlap(wpt.ident == "TOC" || wpt.ident == "TOD" ? true : false)
                    
                  }
                }
//                PolylineAnnotation(lineCoordinates: simbrief.ofp.navlog)
//                  .lineWidth(5)
//                  .lineColor(StyleColor(UIColor.blue))
                
//                if let navlog = simbrief.ofp?.navlog {
//                  ForEvery(navlog.filter { $0.type != "apt" }, id: \.id) { wpt in
//                    MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: Double(wpt.lat) ?? .zero, longitude: Double(wpt.long) ?? .zero)) {
//                      VStack {
//                        Image(systemName: "triangle.fill")
//                          .foregroundStyle(wpt.ident == "TOC" || wpt.ident == "TOD" ? .green : .blue)
//                        Text(wpt.ident)
//                          .padding(6)
//                          .background(.blue)
//                          .foregroundStyle(.white)
//                          .clipShape(Capsule())
//                          .font(.caption)
//                      }
//                    }
//                  }
//                }
              }
            }
            .mapStyle(.init(uri: StyleURI(rawValue: style) ?? StyleURI.dark))
            .ornamentOptions(ornamentOptions)
            .onCameraChanged(action: { changed in
              currentZoom = changed.cameraState.zoom
              coordinateBounds = calculateVisibleMapRegion(center: changed.cameraState.center, zoom: changed.cameraState.zoom, geometry: geometry)
              if let coordinateBounds {
                handleCameraChange(zoom: changed.cameraState.zoom, bounds: coordinateBounds)
              }
            })
            .onAppear {
              proxyMap = proxy
            }
            .alert("Radar Error", isPresented: $rasterRadarAlertVisible) {
              Button("Ok") {
                // TODO: Handle retrying radar
                displayRadar.toggle()
              }
            }
          }
          .ignoresSafeArea()
          
          // MARK: Menu
          VStack(spacing: 5) {
            Button {
              displayRadar.toggle()
            } label: {
              Image(systemName: displayRadar ? "cloud.sun.fill" : "cloud.sun")
            }
            .buttonStyle(.bordered)
            
            Button {
              routeVisible.toggle()
            } label: {
              Image(systemName: routeVisible ? "point.topleft.down.to.point.bottomright.curvepath.fill" : "point.topleft.down.to.point.bottomright.curvepath")
            }
            .buttonStyle(.bordered)
            
            Spacer()
              .frame(height: 15)
            
            Button {
              largeAnnotationsVisible.toggle()
            } label: {
              Image("lg-airport-temp")
                .resizable()
                .frame(width: 38, height: 38)
            }
            Button {
              mediumAnnotationsVisible.toggle()
            } label: {
              Image("md-airport-temp")
                .resizable()
                .frame(width: 38, height: 38)
            }
            Button {
              smallAnnotationsVisible.toggle()
            } label: {
              Image("sm-airport-temp")
                .resizable()
                .frame(width: 38, height: 38)
            }
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

#Preview {
  MapScreen(selectedTab: .constant(1))
}

