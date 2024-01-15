//
//  ContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps


struct MapScreen: View {
  @Binding var selectedTab: Int
  @Environment(SimConnect.self) private var simConnect
  @Environment(Settings.self) private var settings
  
  @State private var viewport: Viewport = .camera(center: CLLocationCoordinate2D(latitude: 39.5, longitude: -98.0), zoom: 3, bearing: 0, pitch: 0)
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  private let style = "mapbox://styles/bradleypregon/clpvnz3y900yn01qmby0f9xn6"
  @State private var coordinateBounds: CoordinateBounds?
  
  let airportJSONModel = AirportJSONModel()
  @State var cacheAirports: [Airport] = []
  @State var airports: [Airport] = []
  @State var selectedAirport: AirportTable?
  @State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
  @State var proxyMap: MapProxy? = nil
  
  @State private var displayRadar: Bool = false {
    didSet {
      if let proxyMap, let map = proxyMap.map {
        displayRadar ? addRasterRadarSource(map) : removeRasterRadarSource(map)
      }
    }
  }
  var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  @State var ownshipImage: Image? = nil
  
  private let radarSourceID = "radar-source"
  @State private var rasterRadarAlertVisible: Bool = false
  
  
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
      GeometryReader { geometry in
        MapReader { proxy in
          Map(viewport: $viewport) {
            ForEvery(airports, id: \.id) { airport in
              PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), isDraggable: false)
                .image(getAirportIcon(for: airport.properties.size.rawValue))
                .onTapGesture {
                  selectedAirport = SQLiteManager.shared.selectAirport(airport.properties.icao)
                  columnVisibility = .all
                }
                .textField(airport.properties.size.rawValue == "Large" || airport.properties.size.rawValue == "Medium" ? airport.properties.icao : "")
                .textOffset([0.0, -1.6])
                .textColor(StyleColor(.white))
                .textHaloBlur(10)
                .textHaloWidth(10)
                .textHaloColor(StyleColor(.black))
                .textSize(13)
              
            }
//            PolygonAnnotation(polygon: testVisiblePolygon)
//              .fillColor(StyleColor(UIColor.blue))
//              .fillOpacity(0.1)
            
            MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: simConnect.simConnectShip?.coordinate.latitude ?? .zero, longitude: simConnect.simConnectShip?.coordinate.longitude ?? .zero)) {
              ownshipImage
            }
          }
          .mapStyle(.init(uri: StyleURI(rawValue: style) ?? StyleURI.dark))
          .ornamentOptions(ornamentOptions)
          .onCameraChanged(action: { changed in
            coordinateBounds = calculateVisibleMapRegion(center: changed.cameraState.center, zoom: changed.cameraState.zoom, geometry: geometry)
            if let coordinateBounds {
              handleCameraChange(zoom: changed.cameraState.zoom, bounds: coordinateBounds)
            }
          })
          .onAppear {
            proxyMap = proxy
          }
          // Publisher to update ownship image
          .onReceive(simConnect.publisher) { _ in
            if let heading = simConnect.simConnectShip?.heading {
              ownshipImage = nil
              updateImageRotation(heading: heading)
            }
          }
          .alert("Radar Error", isPresented: $rasterRadarAlertVisible) {
            Button("Ok") {
              // TODO: Handle retrying radar
              displayRadar.toggle()
            }
          }
        }
        .ignoresSafeArea()
        
        // menu
        VStack {
          Button {
            displayRadar.toggle()
          } label: {
            Image(systemName: displayRadar ? "cloud.sun.fill" : "cloud.sun")
          }
        }
      }
      
    }
    
  }
  
  func updateImageRotation(heading: Double) {
    let img = UIImage(named: "ownship")
    
    if let newImg = img?.rotate(angle: .degrees(heading)) {
      ownshipImage = Image(uiImage: newImg)
    } else {
      if let img {
        ownshipImage = Image(uiImage: img)
      }
    }
  }
  
  func addRasterRadarSource(_ map: MapboxMap) {
    /// image/mapsize/stringpaths (x,y,z)/mapcolor/options(smooth_snow)/filetype
    // TODO: Get current Radar API json string
    
    let jsonPath = "/v2/radar/nowcast_c9a0174466e7"
    let stringPaths = "{z}/{x}/{y}"
    let mapColor = "4"
    let options = "0_1"
    
    let url = String("https://tilecache.rainviewer.com\(jsonPath)/256/\(stringPaths)/\(mapColor)/\(options).png")
    
    var rasterSource = RasterSource(id: radarSourceID)
    rasterSource.tiles = [url]
    rasterSource.tileSize = 256
    
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
  
  func removeRasterRadarSource(_ map: MapboxMap) {
    
    do {
//      try map.removeSource(withId: radarSourceID)
      try map.removeLayer(withId: "radar-layer")
      try map.removeSource(withId: radarSourceID)
    } catch {
      print("Failed to remove radar source. Error: \(error)")
    }
  }
  
  func getAirportIcon(for size: String) -> PointAnnotation.Image? {
    switch size {
    case "Large":
      let temp = UIImage(named: "lg-airport-default")
      if let resizedImg = temp?.resize(newWidth: 44) {
        let img = PointAnnotation.Image(image: resizedImg, name: "lg")
        return img
      }
    case "Medium":
      let temp = UIImage(named: "md-airport-default")
      if let resizedImg = temp?.resize(newWidth: 40) {
        let img = PointAnnotation.Image(image: resizedImg, name: "md")
        return img
      }
    default:
      let temp = UIImage(named: "sm-airport-default")
      let resizedImg = temp?.resize(newWidth: 32)
      
      let img = PointAnnotation.Image(image: resizedImg!, name: "sm")
      return img
    }
    
    let temp = UIImage(named: "sm-airport-default")
    let resizedImg = temp?.resize(newWidth: 32)
    let img = PointAnnotation.Image(image: resizedImg!, name: "sm")
    return img
  }
  
  /**
   Handle zoom level changes and load map annotations
   - Large  Airport Threshold: 5.25
   - Medium  Airport Threshold: 6.0
   - Small Airport Threshold: 6.5
   - Airport Gate Threshold: 14.0
   */
  func handleCameraChange(zoom: CGFloat, bounds: CoordinateBounds) {
    let lgAirportThreshold: CGFloat = 5.0
    let mdAirportThreshold: CGFloat = 6.0
    let smAirportThreshold: CGFloat = 6.5
    
    if zoom >= lgAirportThreshold {
      loadAirports(bounds: bounds, size: "Large")
    } else if zoom < lgAirportThreshold {
      removeAirports(size: "Large")
    }
    if zoom >= mdAirportThreshold {
      loadAirports(bounds: bounds, size: "Medium")
    } else if zoom < mdAirportThreshold {
      removeAirports(size: "Medium")
    }
    if zoom >= smAirportThreshold {
      loadAirports(bounds: bounds, size: "Small")
    } else if zoom < smAirportThreshold {
      removeAirports(size: "Small")
    }
    
  }
  
  func removeAirports(size: String) {
    airports.removeAll(where: { $0.properties.size.rawValue == size })
  }
  
  func loadAirports(bounds: CoordinateBounds, size: String) {
    let prevVisibleAirports = cacheAirports
    let visibleAirports = airportJSONModel.fetchGeoJSON(size: size, bounds: bounds)
    cacheAirports = visibleAirports
    
    let removedAirports = prevVisibleAirports.filter { !visibleAirports.contains($0) }
    let addedAirports = visibleAirports.filter { !prevVisibleAirports.contains($0) }
    
    // Modify airports array in place -> Eliminate recreation
    airports.removeAll(where: { removedAirports.contains($0) })
    airports.append(contentsOf: addedAirports)
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

//#Preview {
//  MapScreen(selectedTab: .constant(1))
//}
