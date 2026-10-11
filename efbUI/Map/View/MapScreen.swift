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
  @Environment(AppCoordinator.self) private var coordinator
  @Environment(SimConnectShipObserver.self) var simConnect
  @Environment(RouteManager.self) private var routeManager
  @Environment(GRDBManager.self) private var grdb
  let customStyle = MapStyle(uri: StyleURI(rawValue: Bundle.main.object(forInfoDictionaryKey: "MapStyleURI") as? String ?? "") ?? .dark)
  
  private let ornamentOptions = OrnamentOptions(scaleBar: ScaleBarViewOptions(visibility: .hidden))
  @State private var viewport: Viewport = .camera(center: .init(latitude: 39.5, longitude: -98.0), zoom: 4, bearing: 0, pitch: 0)
  @State private var currentZoom: CGFloat = 3.0
  @State var proxyMap: MapboxMaps.MapProxy?

  @State var vm = MapViewModel()

  @State var canvas = PKCanvasView()
  @State var selectedTool: PKTool = PKInkingTool(.pen, color: .red, width: 10)
  @State var drawing: PKDrawing = PKDrawing()
  
  @GestureState private var sigmetLongPress = false
  
  @State private var splitViewVisibility: NavigationSplitViewVisibility = .detailOnly
  
  var body: some View {
    @Bindable var vm = vm
    @Bindable var coordinator = coordinator
    
    NavigationSplitView(columnVisibility: $splitViewVisibility) {
      if let detail = vm.selectionDetail {
        switch detail {
        case .airport(let apt):
          AirportAnnotationCalloutView(airport: apt)
        }
      }
    } detail: {
      MapReader { proxy in
        Map(viewport: $viewport) {
          
          /* Testing
           RasterSource(id: "VFR-Sectional")
           .tiles(["https://tiles.arcgis.com/tiles/ssFJjBXIUyZDrSYZ/arcgis/rest/services/VFR_Sectional/MapServer/tile/{z}/{y}/{x}.png"])
           
           RasterLayer(id: "VFR-Sectional-Layer", source: "VFR-Sectional")
           */
          
          GeoJSONSource(id: Id.airportSource)
            .data(.url(Bundle.main.url(forResource: "AirportsMin", withExtension: "geojson")!))
          
          /*
           Toggle to turn off IFR-only or VFR-only airports
           Allow user to change zoom/visible thresholds?
           */
          SymbolLayer(id: Id.smAirports, source: Id.airportSource)
            .filter(Exp(.eq) { Exp(.get) { "size" }; "Small" })
            .minZoom(8)
            .iconImage("airportVfr")
            .iconSize(1.05)
            .iconColor(.lifr)
            .textField(Exp(.get) { "icao" })
            .textOffset(x: 0.0, y: -1.85)
            .textColor(.white)
            .textSize(13)
            .textHaloWidth(1.35)
            .textHaloColor(.black)
          
          SymbolLayer(id: Id.mdAirports, source: Id.airportSource)
            .filter(Exp(.eq) { Exp(.get) { "size" }; "Medium" })
            .minZoom(5)
            .iconImage("airportIfr")
            .iconSize(1.1)
            .iconColor(.lifr)
            .textField(Exp(.get) { "icao" })
            .textOffset(x: 0.0, y: -1.85)
            .textColor(.white)
            .textSize(13)
            .textHaloWidth(1.35)
            .textHaloColor(.black)
          
          SymbolLayer(id: Id.lgAirports, source: Id.airportSource)
            .filter(Exp(.eq) { Exp(.get) { "size" }; "Large" })
            .iconImage("airportIfr")
            .iconSize(1.15)
            .iconColor(.lifr)
            .textField(Exp(.get) { "icao" })
            .textOffset(x: 0.0, y: -1.85)
            .textColor(.white)
            .textSize(13)
            .textHaloWidth(1.35)
            .textHaloColor(.icaoHalo)
          
          TapInteraction(.layer(Id.lgAirports)) { feature, _ in
            guard let icao = feature.properties["icao"]??.rawValue as? String else {
              print("Something went wrong interacting with Lg airport")
              return false
            }
            vm.selection = .airport(icao: icao)
            splitViewVisibility = .all
            return true
          }
          
          TapInteraction(.layer(Id.mdAirports)) { feature, _ in
            guard let icao = feature.properties["icao"]??.rawValue as? String else {
              print("Something went wrong interacting with Md airport")
              return false
            }
            vm.selection = .airport(icao: icao)
            splitViewVisibility = .all
            return true
          }
          
          TapInteraction(.layer(Id.smAirports)) { feature, _ in
            guard let icao = feature.properties["icao"]??.rawValue as? String else {
              print("Something went wrong interacting with Sm airport")
              return false
            }
            vm.selection = .airport(icao: icao)
            splitViewVisibility = .all
            return true
          }
          
          if vm.routeVisible {
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
          if vm.sigmetsVisible {
            PolygonAnnotationGroup(vm.sigmets.filter { !$0.coords.isEmpty }, id: \.airSigmetId) { sigmet in
              var polyCoords: [CLLocationCoordinate2D] = []
              
              for coord in sigmet.coords {
                if let hiAlt = sigmet.altitudeHi2, let loAlt = sigmet.altitudeLow1 {
                  if hiAlt < Int(vm.sigmetSliderRange.upperBound) && loAlt > Int(vm.sigmetSliderRange.lowerBound) {
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
          
          if vm.sidsVisible {
            ForEvery(vm.sidRoute, id: \.self) { route in
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
          
          if vm.starsVisible {
            ForEvery(vm.starRoute, id: \.self) { route in
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
          
          if vm.radarSectionVM.radarVisible {
            radarContent
          }
          
          trafficContent
          
          // TODO: Enroute Comms
          if vm.enrouteCommsVisible {
            PointAnnotationGroup(vm.enrouteComms, id: \.self) { point in
              PointAnnotation(coordinate: CLLocationCoordinate2DMake(point.latitude, point.longitude))
                .textField("\(point.communicationFrequency)")
                .textColor(.white)
                .textSize(12)
            }
          }
          
          // TODO: Gates
          if vm.gatesVisible {
            PointAnnotationGroup(vm.visibleGates, id: \.gateIdentifier) { gate in
              PointAnnotation(coordinate: CLLocationCoordinate2DMake(gate.gateLatitude, gate.gateLongitude))
                .textField(gate.name)
                .textColor(.white)
                .textSize(12)
            }
          }
        }
        .mapStyle(customStyle)
        .ornamentOptions(ornamentOptions)
        .onStyleLoaded { _ in
          // TODO: Move this to function? doesn't really matter
          do {
            try proxy.map?.addImage(.ownship, id: "ownship")
            try proxy.map?.addImage(.traffic, id: "traffic")
            try proxy.map?.addImage(.airportIfr, id: "airportIfr")
            try proxy.map?.addImage(.airportVfr, id: "airportVfr")
          } catch {
            print("Error adding image to map: \(error)")
          }
        }
        .onCameraChanged { context in
          /*
           if context.cameraState.zoom >= 6 {
           // TODO: This will be taxing. We don't really need to query *every* time the camera changes
           if vm.enrouteCommsVisible {
           guard let bounds = proxy.map?.cameraBounds.bounds else { return }
           Task {
           mapViewModel.enrouteComms = await SQLiteManager.shared.getEnrouteComms(in: bounds)
           }
           }
           }
           */
          /*
           if context.cameraState.zoom >= 7.5 {
           mapViewModel.gatesVisible = true
           mapViewModel.fetchVisibleGates()
           } else {
           mapViewModel.gatesVisible = false
           }
           */
        }
        .onAppear {
          proxyMap = proxy
        }
        .task(id: simConnect.ownship) {
          vm.ownship = simConnect.ownship
        }
        .task(id: simConnect.traffic) {
          vm.traffic = simConnect.traffic
        }
        .task(id: coordinator.focusMap) {
          guard coordinator.focusMap, let icao = coordinator.selectedICAO else { return }
          do {
            if let apt = try await grdb.fetchAirport(by: icao), let lat = apt.airportRefLat, let long = apt.airportRefLong {
              let coords: CLLocationCoordinate2D = .init(latitude: lat, longitude: long)
              proxy.camera?.ease(to: .init(center: coords, zoom: 13), duration: 1.25)
            }
          } catch {
            print("Error focusing map: \(error)")
          }
          coordinator.focusMap = false
        }
        .alert("Radar Error", isPresented: $vm.radarSectionVM.rasterRadarAlertVisible) {
          Button("Ok") {
            // TODO: Handle retrying radar
            vm.radarSectionVM.radarVisible = false
          }
        }
        /* Deprecated, use MapViewAnnotation with LongPressGesture
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
        } */

        .task(id: vm.selection) {
          vm.selectionDetail = nil
          guard let selection = vm.selection else { return }
          switch selection {
          case .airport(let icao):
            if let airport = try? await grdb.fetchAirport(by: icao) {
              vm.selectionDetail = .airport(airport)
            } else {
              print("Error setting airport")
            }
          }
        }
        .onTapGesture { _ in vm.selection = nil } // allow tap of map without causing selection to nil
      }
      .ignoresSafeArea()
      .overlay(alignment: .bottom) {
        if vm.drawingEnabled {
          VStack {
            Spacer()
            CanvasToolbarView(
              selTool: $selectedTool,
              onClear: {
                drawing = PKDrawing()
              }
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            DrawingView(drawing: $drawing, tool: $selectedTool)
            
          }
          .frame(width: .infinity, height: 400, alignment: .bottom)
          .background(.ultraThinMaterial)
        }
      }
      .overlay(alignment: .topLeading) {
        VStack(spacing: 5) {
          Button {
            vm.radarSectionVM.radarPopoverVisible.toggle()
          } label: {
            Image(systemName: "cloud.sun")
          }
          .task(id: vm.radarSectionVM.radarPopoverVisible) {
            guard vm.radarSectionVM.radarPopoverVisible else { return }
            do {
              vm.radarSectionVM.currentRadar = try await RainviewerAPI().fetchRadar()
            } catch {
              print("Error fetching current radar: \(error)")
            }
          }
          .popover(isPresented: $vm.radarSectionVM.radarPopoverVisible) {
            VStack {
              // Weather Radar
              Button {
                vm.radarSectionVM.radarVisible.toggle()
              } label: {
                Text("Weather Radar")
              }
              // Satellite Radar
              Button {
                vm.radarSectionVM.satelliteRadarVisible.toggle()
                vm.radarSectionVM.satelliteRadarVisible ? addSatelliteRadarSource() : removeSatelliteRadarSource()
              } label: {
                Text("Satellite Radar")
              }
            }
          }
          
          Toggle("Route", systemImage: vm.routeVisible ? "point.topleft.down.to.point.bottomright.curvepath.fill" : "point.topleft.down.to.point.bottomright.curvepath", isOn: $vm.routeVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          // TODO: Fix long press gesture not working properly
          Toggle("Sigmet", systemImage: vm.sigmetsVisible ? "hazardsign.fill" : "hazardsign", isOn: $vm.sigmetsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .task(id: vm.sigmetsVisible) {
              if vm.sigmetsVisible {
                let sigmetAPI = SigmetAPI()
                do {
                  vm.sigmets = try await sigmetAPI.fetchSigmet()
                } catch {
                  print("Error fetching Sigmet API: \(error)")
                }
              } else {
                vm.sigmets = []
              }
            }
          
          
          Toggle("Satellite", systemImage: vm.mapSatelliteVisible ? "globe.americas.fill" : "globe.americas", isOn: $vm.mapSatelliteVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
            .onChange(of: vm.mapSatelliteVisible) {
              do {
                try proxyMap?.map?.updateLayer(withId: "satellite", type: RasterLayer.self) { layer in
                  layer.visibility = .constant(vm.mapSatelliteVisible ? .visible : .none)
                }
              } catch {
                print("Error changing visibility of Map Satellite layer: \(error)")
              }
            }
          
          Toggle("Communications", systemImage: vm.enrouteCommsVisible ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash", isOn: $vm.enrouteCommsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          Toggle("Drawing", systemImage: vm.drawingEnabled ? "pencil" : "pencil.slash", isOn: $vm.drawingEnabled)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
            .contentTransition(.symbolEffect)
          
          /*
          Spacer()
            .frame(height: 15)
          Toggle("Large", systemImage: vm.lgAirportsVisible ? "l.square.fill" : "l.square", isOn: $vm.lgAirportsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
          Toggle("Medium", systemImage: vm.mdAirportsVisible ? "m.square.fill" : "m.square", isOn: $vm.mdAirportsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
          Toggle("Small", systemImage: vm.smAirportsVisible ? "s.square.fill" : "s.square", isOn: $vm.smAirportsVisible)
            .font(.title2)
            .tint(.mvfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
          */
        }
      }
      .overlay(alignment: .bottomTrailing) {
        if(vm.sigmetsVisible) {
          Button {
            vm.sigmetMenuPopoverVisible.toggle()
          } label: {
            Image(systemName: "hazardsign.fill")
              .font(.title2)
              .foregroundStyle(.mvfr)
          }
          .popover(isPresented: $vm.sigmetMenuPopoverVisible) {
            VStack {
              Text("Sigmet Altitudes")
              RangedSliderView(value: $vm.sigmetSliderRange, bounds: 0...50000,  step: 1000)
            }
            .frame(idealWidth: 250)
            .padding()
            .padding([.leading, .trailing, .bottom], 10)
          }
        }
      }
    }
    .ignoresSafeArea()
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


private enum Id {
  static let airportSource = "AirportsSource"
  static let lgAirports = "AirportsLarge"
  static let mdAirports = "AirportsMedium"
  static let smAirports = "AirportsSmall"
}

#Preview {
  MapScreen()
}
