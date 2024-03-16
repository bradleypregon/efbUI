//
//  AirportJSONViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 6/10/22.
//

//import Foundation
import SwiftUI
//@_spi(Experimental) import MapboxMaps
//import Combine

@Observable
final class AirportJSONModel {
  let path = Bundle.main.path(forResource: "Airports", ofType: "json")
  var airports: [AirportSchema] = []
  
  init() {
    if let path {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        airports = try JSONDecoder().decode([AirportSchema].self, from: data)
      } catch {
        print("Error decoding Airport JSON from Airports.json: \(error)")
      }
    }
  }
  
//  func fetchVisibleAirports(size: String, bounds: CoordinateBounds) {
//      for airport in airports {
//        if !airport.visible && airport.properties.size.rawValue == size && bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
//          airport.visible = true
//        } else if airport.visible && !bounds.contains(forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long), wrappedCoordinates: false) {
//          airport.visible = false
//        }
//      }
//  }
  
//  func hideAirports(size: String) {
//      for airport in airports {
//        if airport.visible && airport.properties.size.rawValue == size {
//          airport.visible = false
//        }
//      }
//  }
  
//  func fetchGeoJSON(size: String, bounds: CoordinateBounds) -> [Airport] {
//    let filter = airports
//      .filter { airport in
//        let airportSize = airport.properties.size.rawValue
//        return airportSize == size || AirportSize(rawValue: airportSize)! < AirportSize(rawValue: size)!
//      }
//      .filter { airport in
//        bounds.contains(
//          forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long),
//          wrappedCoordinates: false
//        )
//      }
//    return Array(filter)
//  }
  
//  enum AirportSize: String, Comparable {
//    case Small
//    case Medium
//    case Large
//    
//    static func < (lhs: AirportSize, rhs: AirportSize) -> Bool {
//      let sizeOrder: [AirportSize] = [.Large, .Medium, .Small]
//      guard let lhsIndex = sizeOrder.firstIndex(of: lhs),
//            let rhsIndex = sizeOrder.firstIndex(of: rhs) else {
//        return false
//      }
//      return lhsIndex < rhsIndex
//    }
//  }
  
}
