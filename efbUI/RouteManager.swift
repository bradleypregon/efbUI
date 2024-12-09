//
//  RouteManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/5/24.
//

import SwiftUI
import Observation
import CoreLocation

/*
 Generic route type that includes all details of other waypoints/airports/etc
  - How to include details from simbrief? (TOD, TOC, various fuel)
 How to handle departures/arrivals?
 
 ID
 coordinates
 name? VORs have two names, one short and one long
 type (vor, gps)
 
 ...
 // old notes here
 
 // Linked list
 // Each node can be an airport, vor, navaid, departure, arrival, any type of navigation aid with a coordinate
 // upon simbrief api fetch, compile route and load it into LinkedList

 // Typical route format:
 // head -> Airport
 // nodes -> each route component
 // tail -> Airport
 
 // TODO: Create heterogeneous-type array. Blank at first
 // Hetero Array: Airports, VOR, VORTAC, NBD, GPS Waypoints, what about SIDS/STARs?
 // Linked List???
 
 // User: Have ability to create own route, or load SimBrief
 // If loading via simbrief, iterate through Navlog and query DATABASE to create route waypoint objects
 
 // in map screen, perhaps OnTap of annotation of route, if in simbrief route, display details?
 
 // ISSUE: Simbrief Navlog has a lot of extra data. TOC,TOD, Windshear, wind, planned alt, etc
 // Perhaps allow for simbrief route OR custom route?
 //  - if going this route, no need to query database for simbrief.. just use "as is"
 
//  func loadSimbrief() {
//    if let nav = simbrief.ofp?.navlog {
//      for wpt in nav {
//        array.append(wpt.name)
//      }
//    }
//  }
 */


enum WaypointType {
  case vor
  case sid
  case star
  case gps
}

struct MyWaypoint: Identifiable, Hashable {
  let id: String = UUID().uuidString
  let lat: Double
  let long: Double
  let type: WaypointType
  let name: String
}

@Observable
class RouteManager {
  var waypoints: [MyWaypoint] = []
}
