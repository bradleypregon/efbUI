//
//  RouteManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/5/24.
//

import SwiftUI
import Observation

@Observable
class RouteManager {
  static let shared = RouteManager()
  
  var array: [String] = []
  
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
  
  func printRoute() {
    for wpt in array {
      print(wpt)
    }
  }
}
