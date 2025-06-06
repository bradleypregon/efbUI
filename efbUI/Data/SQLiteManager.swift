//
//  SQLiteManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/13/23.
//

import Foundation
import SQLite
typealias Expression = SQLite.Expression
import MapboxMaps

struct QueryAirportTextResult: Equatable, Identifiable {
  let airportIdentifier: String
  let airportName: String
  
  var id: String {
    airportIdentifier
  }
}

class SQLiteManager {
  @MainActor static let shared = SQLiteManager()
  private var db: Connection? = nil
  
  private init() {
    do {
      let path = Bundle.main.path(forResource: "navdata", ofType: "db")
      if let path {
        db = try Connection(path, readonly: true)
      } else {
        print("Error occured with SQLiteManager Database Path")
      }
    } catch let error {
      db = nil
      print("Error initializing Database: \(error)")
    }
  }
  
  func queryAirports(_ query: String) -> [AirportTable] {
    guard let database = db else { return [] }
    var airports: [AirportTable] = []
    
    do {
      let table = Table("tbl_airports")
      let airportName = Expression<String>("airport_name")
      let airportIdentifier = Expression<String>("airport_identifier")
      
      let queryCondition = airportName.like("%\(query)%") || airportIdentifier.like("%\(query)%")
      for temp in try database.prepare(table.filter(queryCondition).limit(100)) {
        
        guard let airport = selectAirport(temp[airportIdentifier]) else { return [] }
        airports.append(airport)
      }
      return airports
    } catch let error {
      print("Error querying AirportTable: \(error)")
      return []
    }
  }
  
  func queryAirportsAsync(_ query: String) async -> [AirportTable] {
    guard let database = db else { return [] }
    var airports: [AirportTable] = []
    
    do {
      let table = Table("tbl_airports")
      let airportName = Expression<String>("airport_name")
      let airportIdentifier = Expression<String>("airport_identifier")
      
      let queryCondition = airportName.like("%\(query)%") || airportIdentifier.like("%\(query)%")
      for temp in try database.prepare(table.filter(queryCondition).limit(100)) {
        
        guard let airport = selectAirport(temp[airportIdentifier]) else { return [] }
        airports.append(airport)
      }
      return airports
    } catch let error {
      print("Error querying AirportTable: \(error)")
      return []
    }
  }
  
  func selectAirport(_ airport: String) -> AirportTable? {
    guard let database = db else { return nil }
    let table = Table("tbl_airports")
    
    let areaCode = Expression<String?>("area_code")
    let icaoCode = Expression<String>("icao_code")
    let airportIdentifier = Expression<String>("airport_identifier")
    let airportIdentifier3letter = Expression<String?>("airport_identifier_3letter")
    let airportName = Expression<String>("airport_name")
    let airportRefLatitude = Expression<Double>("airport_ref_latitude")
    let airportRefLongitude = Expression<Double>("airport_ref_longitude")
    let ifrCapability = Expression<String?>("ifr_capability")
    let longestRunwaySurfaceCode = Expression<String>("longest_runway_surface_code")
    let elevation = Expression<Int64>("elevation")
    let transitionAltitude = Expression<Int64?>("transition_altitude")
    let transitionLevel = Expression<Int64?>("transition_level")
    let speedLimit = Expression<Int64?>("speed_limit")
    let speedLimitAltitude = Expression<Int64?>("speed_limit_altitude")
    let iataAtaDesignator = Expression<String?>("iata_ata_designator")
    let id = Expression<String>("id")
    
    let queryCondition = (airportIdentifier == airport)
    do {
      for res in try database.prepare(table.filter(queryCondition)) {
        let airport = AirportTable(
          areaCode: res[areaCode] ?? "",
          icaoCode: res[icaoCode],
          airportIdentifier: res[airportIdentifier],
          airportIdentifier3Letter: res[airportIdentifier3letter] ?? "",
          airportName: res[airportName],
          airportRefLat: res[airportRefLatitude],
          airportRefLong: res[airportRefLongitude],
          ifrCapibility: res[ifrCapability] ?? "N",
          longestRunwaySurfaceCode: res[longestRunwaySurfaceCode],
          elevation: res[elevation],
          transitionAltitude: res[transitionAltitude] ?? .zero,
          transitionLevel: res[transitionLevel] ?? .zero,
          speedLimit: res[speedLimit] ?? .zero,
          speedLimitAltitude: res[speedLimitAltitude] ?? .zero,
          iataAtaDesignator: res[iataAtaDesignator] ?? "",
          id: res[id]
        )
        return airport
      }
      return nil
    } catch let error {
      print("Issue selecting an airport: \(error)")
      return nil
    }
  }
  
  func getAirportComms(_ airport: String) -> [AirportCommunicationTable] {
    guard let database = db else { return [] }
    var comms: [AirportCommunicationTable] = []
    
    do {
      let table = Table("tbl_airport_communication")
      
      let areaCode = Expression<String?>("area_code")
      let icaoCode = Expression<String?>("icao_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let communicationType = Expression<String?>("communication_type")
      let communicationFrequency = Expression<Double?>("communication_frequency")
      let frequencyUnits = Expression<String?>("frequency_units")
      let serviceIndicator = Expression<String?>("service_indicator")
      let callsign = Expression<String?>("callsign")
      let latitude = Expression<Double?>("latitude")
      let longitude = Expression<Double?>("longitude")
      
      let queryCondition = (airportIdentifier == airport)
      do {
        for res in try database.prepare(table.filter(queryCondition)) {
          let comm = AirportCommunicationTable(areaCode: res[areaCode] ?? "", icaoCode: res[icaoCode] ?? "", airportIdentifier: res[airportIdentifier], communicationType: res[communicationType] ?? "", communicationFrequency: res[communicationFrequency] ?? 0.0, frequencyUnits: res[frequencyUnits] ?? "", serviceIndicator: res[serviceIndicator] ?? "", callsign: res[callsign] ?? "", latitude: res[latitude] ?? 0.0, longitude: res[longitude] ?? 0.0)
          comms.append(comm)
        }
        return comms
      }
    } catch let error {
      print("Error querying Airport Communications: \(error)")
      return []
    }
  }
  
  // TODO: Deprecate
  func getAirportsInMapRect(minLat: Double, maxLat: Double, minLong: Double, maxLong: Double, ifr: Bool) -> [AirportTable] {
    guard let database = db else { return [] }
    var airports: [AirportTable] = []
    
    do {
      let table = Table("tbl_airports")
      
      let areaCode = Expression<String?>("area_code")
      let icaoCode = Expression<String>("icao_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let airportIdentifier3letter = Expression<String?>("airport_identifier_3letter")
      let airportName = Expression<String>("airport_name")
      let airportRefLatitude = Expression<Double>("airport_ref_latitude")
      let airportRefLongitude = Expression<Double>("airport_ref_longitude")
      let ifrCapability = Expression<String?>("ifr_capability")
      let longestRunwaySurfaceCode = Expression<String>("longest_runway_surface_code")
      let elevation = Expression<Int64>("elevation")
      let transitionAltitude = Expression<Int64?>("transition_altitude")
      let transitionLevel = Expression<Int64?>("transition_level")
      let speedLimit = Expression<Int64>("speed_limit")
      let speedLimitAltitude = Expression<Int64>("speed_limit_altitude")
      let iataAtaDesignator = Expression<String?>("iata_ata_designator")
      let id = Expression<String>("id")
      
      // airportRefLatitude BETWEEN minLat AND maxLat AND airportRefLongitude BETWEEN minLong AND maxLong
      let queryCondition = (airportRefLatitude <= maxLat && airportRefLatitude >= minLat) && (airportRefLongitude <= maxLong && airportRefLongitude >= minLong) && (ifr ? ifrCapability == "Y" : ifrCapability == "N")
      
      for temp in try database.prepare(table.filter(queryCondition)) {
        if temp[ifrCapability] == "N" {
          print("non ifr-capable airport: \(temp[airportName])")
        }
        let res = AirportTable(
          areaCode: temp[areaCode] ?? "",
          icaoCode: temp[icaoCode],
          airportIdentifier: temp[airportIdentifier],
          airportIdentifier3Letter: temp[airportIdentifier3letter] ?? "",
          airportName: temp[airportName],
          airportRefLat: temp[airportRefLatitude],
          airportRefLong: temp[airportRefLongitude],
          ifrCapibility: temp[ifrCapability] ?? "N",
          longestRunwaySurfaceCode: temp[longestRunwaySurfaceCode],
          elevation: temp[elevation],
          transitionAltitude: temp[transitionAltitude] ?? .zero,
          transitionLevel: temp[transitionLevel] ?? .zero,
          speedLimit: temp[speedLimit],
          speedLimitAltitude: temp[speedLimitAltitude],
          iataAtaDesignator: temp[iataAtaDesignator] ?? "",
          id: temp[id]
        )
        airports.append(res)
      }
      return airports
    } catch let error {
      print("Error in getAirportsInMapRect: \(error)")
      return []
    }
  }
  
  func getAirportRunways(_ icao: String) -> [RunwayTable] {
    guard let database = db else { return [] }
    var runways: [RunwayTable] = []
    
    do {
      let table = Table("tbl_runways")
      
      let areaCode = Expression<String?>("area_code")
      let icaoCode = Expression<String?>("icao_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let runwayIdentifier = Expression<String>("runway_identifier")
      let runwayLatitude = Expression<Double?>("runway_latitude")
      let runwayLongitude = Expression<Double?>("runway_longitude")
      let runwayGradient = Expression<Double?>("runway_gradient")
      let runwayMagBearing = Expression<Double?>("runway_magnetic_bearing")
      let runwayTrueBearing = Expression<Double?>("runway_true_bearing")
      let landingThresholdElevation = Expression<Int?>("landing_threshold_elevation")
      let displacedThresholdDistance = Expression<Int?>("displaced_threshold_distance")
      let thresholdCrossingHeight = Expression<Int?>("threshold_crossing_height")
      let runwayLength = Expression<Int?>("runway_length")
      let runwayWidth = Expression<Int?>("runway_width")
      let llzIdentifier = Expression<String?>("llz_identifier")
      let llzMLSGLSCategory = Expression<String?>("llz_mls_gls_category")
      let surfaceCode = Expression<Int?>("surface_code")
      let id = Expression<String?>("id")
      
      let queryCondition = (airportIdentifier == icao)
      do {
        for res in try database.prepare(table.filter(queryCondition)) {
          let runway = RunwayTable(areaCode: res[areaCode] ?? "", icaoCode: res[icaoCode] ?? "", airportIdentifier: res[airportIdentifier], runwayIdentifier: res[runwayIdentifier], runwayLatitude: res[runwayLatitude] ?? .zero, runwayLongitude: res[runwayLongitude] ?? .zero, runwayGradient: res[runwayGradient] ?? .zero, runwayMagneticBearing: res[runwayMagBearing] ?? .zero, runwayTrueBearing: res[runwayTrueBearing] ?? .zero, landingThresholdElevation: res[landingThresholdElevation] ?? .zero, displacedThresholdDistance: res[displacedThresholdDistance] ?? .zero, thresholdCrossingHeight: res[thresholdCrossingHeight] ?? .zero, runwayLength: res[runwayLength] ?? .zero, runwayWidth: res[runwayWidth] ?? .zero, llzIdentifier: res[llzIdentifier] ?? "", llz_mls_gls_category: res[llzMLSGLSCategory] ?? "", surfaceCode: res[surfaceCode] ?? .zero, id: res[id] ?? "")
          runways.append(runway)
        }
        return runways
      }
    } catch let error {
      print("Error fetching Airport Runways: \(error)")
      return []
    }
  }
  
  func getAirportGates(_ icao: String) -> [GateTable] {
    guard let database = db else { return [] }
    var gates: [GateTable] = []
    
    do {
      let table = Table("tbl_gate")
      let areaCode = Expression<String?>("area_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let icaoCode = Expression<String>("icao_code")
      let gateId = Expression<String>("gate_identifier")
      let gateLat = Expression<Double>("gate_latitude")
      let gateLong = Expression<Double>("gate_longitude")
      let name = Expression<String>("name")
      
      let query = (icao == airportIdentifier)
      for temp in try database.prepare(table.filter(query)) {
        let result = GateTable(
          areaCode: temp[areaCode] ?? "",
          airportIdentifier: temp[airportIdentifier],
          icaoCode: temp[icaoCode],
          gateIdentifier: temp[gateId],
          gateLatitude: temp[gateLat],
          gateLongitude: temp[gateLong],
          name: temp[name]
        )
        gates.append(result)
      }
      return gates
    } catch let error {
      print("Issue querying gates in getAirportGates(): \(error)")
      return []
    }
  }
  
  func getAirportProcedures(_ icao: String, procedure: String) -> [ProcedureTable] {
    guard let database = db else { return [] }
    var procedures: [ProcedureTable] = []
    
    do {
      let table = Table(procedure)
      let areaCode = Expression<String?>("area_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let procedureIdentifier = Expression<String>("procedure_identifier")
      let routeType = Expression<String?>("route_type")
      let transitionIdentifier = Expression<String?>("transition_identifier")
      let seqno = Expression<Int?>("seqno")
      let waypointICAOCode = Expression<String?>("waypoint_icao_code")
      let waypointIdentifier = Expression<String?>("waypoint_identifier")
      let waypointLatitude = Expression<Double?>("waypoint_latitude")
      let waypointLongitude = Expression<Double?>("waypoint_longitude")
      let waypointDescriptionCode = Expression<String?>("waypoint_description_code")
      let turnDirection = Expression<String?>("turn_direction")
      let rnp = Expression<Double?>("rnp")
      let pathTermination = Expression<String?>("path_termination")
      let recommendedNavaid = Expression<String?>("recommanded_navaid")
      let recommendedNavaidLatitude = Expression<Double?>("recommanded_navaid_latitude")
      let recommendedNavaidLongitude = Expression<Double?>("recommanded_navaid_longitude")
      let arcRadius = Expression<Double?>("arc_radius")
      let theta = Expression<Double?>("theta")
      let rho = Expression<Double?>("rho")
      let magneticCourse = Expression<Double?>("magnetic_course")
      let routeDistanceHoldingDistanceTime = Expression<Double?>("route_distance_holding_distance_time")
      let distanceTime = Expression<String?>("distance_time")
      let altitudeDescription = Expression<String?>("altitude_description")
      let altitude1 = Expression<Int?>("altitude1")
      let altitude2 = Expression<Int?>("altitude2")
      let transitionAltitude = Expression<Int?>("transition_altitude")
      let speedLimitDescription = Expression<String?>("speed_limit_description")
      let speedLimit = Expression<Int?>("speed_limit")
      let verticalAngle = Expression<Double?>("vertical_angle")
      let centerWaypoint = Expression<String?>("center_waypoint")
      let centerWaypointLatitude = Expression<Double?>("center_waypoint_latitude")
      let centerWaypointLongitude = Expression<Double?>("center_waypoint_longitude")
      let aircraftCategory = Expression<String?>("aircraft_category")
      let id = Expression<String>("id")
      let recommendedId = Expression<String?>("recommanded_id")
      let centerId = Expression<String?>("center_id")
      
      let query = (icao == airportIdentifier)
      for temp in try database.prepare(table.filter(query)) {
        let result = ProcedureTable(
          areaCode: temp[areaCode] ?? "",
          airportIdentifier: temp[airportIdentifier],
          procedureIdentifier: temp[procedureIdentifier],
          routeType: temp[routeType] ?? "",
          transitionIdentifier: temp[transitionIdentifier] ?? "",
          seqno: temp[seqno] ?? .zero,
          waypointICAOCode: temp[waypointICAOCode] ?? "",
          waypointIdentifier: temp[waypointIdentifier] ?? "",
          waypointLatitude: temp[waypointLatitude] ?? .zero,
          waypointLongitude: temp[waypointLongitude] ?? .zero,
          waypointDescriptionCode: temp[waypointDescriptionCode] ?? "",
          turnDirection: temp[turnDirection] ?? "",
          rnp: temp[rnp] ?? .zero,
          pathTermination: temp[pathTermination] ?? "",
          recommendedNavaid: temp[recommendedNavaid] ?? "",
          recommendedNavaidLatitude: temp[recommendedNavaidLatitude] ?? .zero,
          recommendedNavaidLongitude: temp[recommendedNavaidLongitude] ?? .zero,
          arcRadius: temp[arcRadius] ?? .zero,
          theta: temp[theta] ?? .zero,
          rho: temp[rho] ?? .zero,
          magneticCourse: temp[magneticCourse] ?? .zero,
          routeDistanceHoldingDistanceTime: temp[routeDistanceHoldingDistanceTime] ?? .zero,
          distanceTime: temp[distanceTime] ?? "",
          altitudeDescription: temp[altitudeDescription] ?? "",
          altitude1: temp[altitude1] ?? .zero,
          altitude2: temp[altitude2] ?? .zero,
          transitionAltitude: temp[transitionAltitude] ?? .zero,
          speedLimitDescription: temp[speedLimitDescription] ?? "",
          speedLimit: temp[speedLimit] ?? .zero,
          verticalAngle: temp[verticalAngle] ?? .zero,
          centerWaypoint: temp[centerWaypoint] ?? "",
          centerWaypointLatitude: temp[centerWaypointLatitude] ?? .zero,
          centerWaypointLongitude: temp[centerWaypointLongitude] ?? .zero,
          aircraftCategory: temp[aircraftCategory] ?? "",
          id: temp[id],
          recommendedId: temp[recommendedId] ?? "",
          centerId: temp[centerId] ?? ""
        )
        procedures.append(result)
      }
      return procedures
    } catch let error {
      print("Error querying Departures: \(error)")
      return []
    }
  }
  
  func getAirports() -> [AirportTable] {
    guard let database = db else { return [] }
    var airports: [AirportTable] = []
    
    do {
      let table = Table("tbl_airports")
      
      let areaCode = Expression<String?>("area_code")
      let icaoCode = Expression<String>("icao_code")
      let airportIdentifier = Expression<String>("airport_identifier")
      let airportIdentifier3letter = Expression<String?>("airport_identifier_3letter")
      let airportName = Expression<String>("airport_name")
      let airportRefLatitude = Expression<Double>("airport_ref_latitude")
      let airportRefLongitude = Expression<Double>("airport_ref_longitude")
      let ifrCapability = Expression<String?>("ifr_capability")
      let longestRunwaySurfaceCode = Expression<String>("longest_runway_surface_code")
      let elevation = Expression<Int64>("elevation")
      let transitionAltitude = Expression<Int64?>("transition_altitude")
      let transitionLevel = Expression<Int64?>("transition_level")
      let speedLimit = Expression<Int64?>("speed_limit")
      let speedLimitAltitude = Expression<Int64?>("speed_limit_altitude")
      let iataAtaDesignator = Expression<String?>("iata_ata_designator")
      let id = Expression<String>("id")
      
      for temp in try database.prepare(table) {
        let result = AirportTable(
          areaCode: temp[areaCode] ?? "",
          icaoCode: temp[icaoCode],
          airportIdentifier: temp[airportIdentifier],
          airportIdentifier3Letter: temp[airportIdentifier3letter] ?? "",
          airportName: temp[airportName],
          airportRefLat: temp[airportRefLatitude],
          airportRefLong: temp[airportRefLongitude],
          ifrCapibility: temp[ifrCapability] ?? "N",
          longestRunwaySurfaceCode: temp[longestRunwaySurfaceCode],
          elevation: temp[elevation],
          transitionAltitude: temp[transitionAltitude] ?? .zero,
          transitionLevel: temp[transitionLevel] ?? .zero,
          speedLimit: temp[speedLimit] ?? .zero,
          speedLimitAltitude: temp[speedLimitAltitude] ?? .zero,
          iataAtaDesignator: temp[iataAtaDesignator] ?? "",
          id: temp[id]
        )
        airports.append(result)
      }
      return airports
    } catch let error {
      print("Error in getAirports(): \(error)")
      return []
    }
  }
  
  func getEnrouteComms(in bounds: CoordinateBounds) async -> [EnrouteCommTable] {
    guard let database = db else { return [] }
    var enrouteComms: [EnrouteCommTable] = []
    do {
      let table = Table("tbl_enroute_communication")
      let areaCode = Expression<String?>("area_code")
      let firRDOIdent = Expression<String?>("fir_rdo_ident")
      let firUIRIndicator = Expression<String?>("fir_uir_indicator")
      let communicationType = Expression<String?>("communication_type")
      let communicationFrequency = Expression<Double?>("communication_frequency")
      let frequencyUnits = Expression<String?>("frequency_units")
      let serviceIndicator = Expression<String?>("service_indicator")
      let remoteName = Expression<String?>("remote_name")
      let callsign = Expression<String?>("callsign")
      let latitude = Expression<Double>("latitude")
      let longitude = Expression<Double>("longitude")
      
      var query: Table
      let minLat = bounds.southwest.latitude
      let maxLat = bounds.northeast.latitude
      let minLon = bounds.southwest.longitude
      let maxLon = bounds.northeast.longitude
      
      if minLon <= maxLon {
        query = table.filter(latitude >= minLat && latitude <= maxLat &&
                             (longitude >= minLon && longitude <= maxLon) && areaCode == "USA" && firUIRIndicator == "U" && frequencyUnits == "V")
      } else {
        query = table.filter(latitude >= minLat && latitude <= maxLat &&
                             (longitude >= minLon || longitude <= maxLon) && areaCode == "USA" && firUIRIndicator == "U" && frequencyUnits == "V")
      }
      
      do {
        for res in try database.prepare(query) {
          let comm: EnrouteCommTable = .init(areaCode: res[areaCode] ?? "", firRDOIdent: res[firRDOIdent] ?? "", firUIRIndicator: res[firUIRIndicator] ?? "", communicationType: res[communicationType] ?? "", communicationFrequency: res[communicationFrequency] ?? .zero, frequencyUnits: res[frequencyUnits] ?? "", serviceIndicator: res[serviceIndicator] ?? "", remoteName: res[remoteName] ?? "", callsign: res[callsign] ?? "", latitude: res[latitude], longitude: res[longitude])
          enrouteComms.append(comm)
        }
        return enrouteComms
      }
    } catch let error {
      print("Error querying enroute comms: \(error)")
      return []
    }
  }
  
  // TODO: uhh fix this
  // I totally hate everything about this.
  // Please, have a drink (or two?) before trying to read this
  func searchTables(query: String) -> [MyWaypoint] {
    guard let database = db else { return [] }
    let airportTable = Table("tbl_airports")
    let airportIdentifier = Expression<String>("airport_identifier")
    let airportName = Expression<String>("airport_name")
    let airportLatitude = Expression<Double>("airport_ref_latitude")
    let airportLongitude = Expression<Double>("airport_ref_longitude")
    
    let enrouteNDBNavaidsTable = Table("tbl_enroute_ndbnavaids")
    let enrouteNDBIdentifier = Expression<String>("ndb_identifier")
    let enrouteNDBName = Expression<String>("ndb_name")
    let enrouteNDBLatitude = Expression<Double>("ndb_latitude")
    let enrouteNDBLongitude = Expression<Double>("ndb_longitude")
    
    let terminalNDBNavaidsTable = Table("tbl_terminal_ndbnavaids")
    let terminalNDBIdentifier = Expression<String>("ndb_identifier")
    let terminalNDBName = Expression<String>("ndb_name")
    let terminalNDBLatitude = Expression<Double>("ndb_latitude")
    let terminalNDBLongitude = Expression<Double>("ndb_longitude")
    
    let vhfNavaidsTable = Table("tbl_vhfnavaids")
    let vhfIdentifier = Expression<String>("vor_identifier")
    let vhfName = Expression<String>("vor_name")
    let vhfLatitude = Expression<Double>("vor_latitude")
    let vhfLongitude = Expression<Double>("vor_longitude")
    
    let enrouteWaypointsTable = Table("tbl_enroute_waypoints")
    let enrouteWaypointIdentifier = Expression<String>("waypoint_identifier")
    let enrouteWaypointName = Expression<String>("waypoint_name")
    let enrouteWaypointLatitude = Expression<Double>("waypoint_latitude")
    let enrouteWaypointLongitude = Expression<Double>("waypoint_longitude")
    
    let terminalWaypointsTable = Table("tbl_terminal_waypoints")
    let terminalWaypointIdentifier = Expression<String>("waypoint_identifier")
    let terminalWaypointName = Expression<String>("waypoint_name")
    let terminalWaypointLatitude = Expression<Double>("waypoint_latitude")
    let terminalWaypointLongitude = Expression<Double>("waypoint_longitude")

    var results: [MyWaypoint] = []
    do {
      let airportQuery = airportTable.filter(airportIdentifier == query).select(airportIdentifier,airportName,airportLatitude,airportLongitude)
      for row in try database.prepare(airportQuery) {
        results.append(MyWaypoint(identifier: row[airportIdentifier], name: row[airportName], lat: row[airportLatitude], long: row[airportLongitude], type: .airport))
      }
      
      let enrouteNDBNavaidQuery = enrouteNDBNavaidsTable.filter(enrouteNDBIdentifier == query).select(enrouteNDBIdentifier,enrouteNDBName,enrouteNDBLatitude,enrouteNDBLongitude)
      for row in try database.prepare(enrouteNDBNavaidQuery) {
        results.append(MyWaypoint(identifier: row[enrouteNDBIdentifier], name: row[enrouteNDBName], lat: row[enrouteNDBLatitude], long: row[enrouteNDBLongitude], type: .navaid))
      }
      
      let terminalNDBNavaidQuery = terminalNDBNavaidsTable.filter(terminalNDBIdentifier == query).select(terminalNDBIdentifier,terminalNDBName, terminalNDBLatitude,terminalNDBLongitude)
      for row in try database.prepare(terminalNDBNavaidQuery) {
        results.append(MyWaypoint(identifier: row[terminalNDBIdentifier], name: row[terminalNDBName], lat: row[terminalNDBLatitude], long: row[terminalNDBLongitude], type: .navaid))
      }
      
      let vhfNavaidQuery = vhfNavaidsTable.filter(vhfIdentifier == query).select(vhfIdentifier,vhfName, vhfLatitude,vhfLongitude)
      for row in try database.prepare(vhfNavaidQuery) {
        results.append(MyWaypoint(identifier: row[vhfIdentifier], name: row[vhfName], lat: row[vhfLatitude], long: row[vhfLongitude], type: .navaid))
      }
      
      let enrouteWaypointsQuery = enrouteWaypointsTable.filter(enrouteWaypointIdentifier == query).select(enrouteWaypointIdentifier,enrouteWaypointName, enrouteWaypointLatitude,enrouteWaypointLongitude)
      for row in try database.prepare(enrouteWaypointsQuery) {
        results.append(MyWaypoint(identifier: row[enrouteWaypointIdentifier], name: row[enrouteWaypointName], lat: row[enrouteWaypointLatitude], long: row[enrouteWaypointLongitude], type: .waypoint))
      }
      
      let terminalWaypointsQuery = terminalWaypointsTable.filter(terminalWaypointIdentifier == query).select(terminalWaypointIdentifier,terminalWaypointName, terminalWaypointLatitude,terminalWaypointLongitude)
      for row in try database.prepare(terminalWaypointsQuery) {
        results.append(MyWaypoint(identifier: row[terminalWaypointIdentifier], name: row[terminalWaypointName], lat: row[terminalWaypointLatitude], long: row[terminalWaypointLongitude], type: .waypoint))
      }

    return results
    } catch let error {
      print("Error querying waypoints: \(error)")
      return []
    }
  }
  
}
