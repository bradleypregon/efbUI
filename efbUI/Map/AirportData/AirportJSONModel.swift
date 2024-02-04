//
//  AirportJSONViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 6/10/22.
//

import Foundation
import SwiftUI
@_spi(Experimental) import MapboxMaps

final class AirportJSONModel {
  let path = Bundle.main.path(forResource: "Airports", ofType: "geojson")
  var airports: Set<Airport> = Set<Airport>()
  
  init() {
    if let path {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let temp = try JSONDecoder().decode([Airport].self, from: data)
        airports = Set(temp)
      } catch {
        print("Error decoding Airport JSON from Airports.GeoJSON: \(error)")
      }
    }
    
  }
  
  func fetchGeoJSON(size: String, bounds: CoordinateBounds) -> [Airport] {
    let filter = airports
      .filter { airport in
        let airportSize = airport.properties.size.rawValue
        return airportSize == size || AirportSize(rawValue: airportSize)! < AirportSize(rawValue: size)!
      }
      .filter { airport in
        bounds.contains(
          forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long),
          wrappedCoordinates: false
        )
      }
    return Array(filter)
//    if let path {
//      do {
//        let data = try Data(contentsOf: URL(fileURLWithPath: path))
//        let filteredAirports = try JSONDecoder().decode([Airport].self, from: data)
//          .filter { airport in
//            let airportSize = airport.properties.size.rawValue
//            return airportSize == size || AirportSize(rawValue: airportSize)! < AirportSize(rawValue: size)!
//          }
//          .filter { airport in
//            bounds.contains(
//              forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long),
//              wrappedCoordinates: true
//            )
//          }
//        return filteredAirports
//      } catch let error {
//        print("Error decoding Airport JSON from Airport.GeoJSON: \(error)")
//        return []
//      }
//    }
//    return []
  }
  
  enum AirportSize: String, Comparable {
    case Small
    case Medium
    case Large
    
    static func < (lhs: AirportSize, rhs: AirportSize) -> Bool {
      let sizeOrder: [AirportSize] = [.Large, .Medium, .Small]
      guard let lhsIndex = sizeOrder.firstIndex(of: lhs),
            let rhsIndex = sizeOrder.firstIndex(of: rhs) else {
        return false
      }
      return lhsIndex < rhsIndex
    }
  }
  
}
