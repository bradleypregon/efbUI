//
//  AirportJSONViewModel.swift
//  efbUI
//
//  Created by Bradley Pregon on 6/10/22.
//

import Foundation
import SwiftUI
@_spi(Experimental) import MapboxMaps

class AirportJSONModel {
  
  let jsonFile = "Airports"
  let jsonFileType = "geojson"
  
  func fetchGeoJSON(size: String, bounds: CoordinateBounds) -> [Airport] {
    if let path = Bundle.main.path(forResource: jsonFile, ofType: jsonFileType) {
      
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let filteredAirports = try JSONDecoder().decode([Airport].self, from: data)
          .filter { airport in
            let airportSize = airport.properties.size.rawValue
            return airportSize == size || AirportSize(rawValue: airportSize)! < AirportSize(rawValue: size)!
          }
          .filter { airport in
            bounds.contains(
              forPoint: CLLocationCoordinate2D(latitude: airport.coordinates.lat, longitude: airport.coordinates.long),
              wrappedCoordinates: true
            )
          }
        
        return filteredAirports
      } catch let error {
        print("Error decoding Airport JSON from Airport.GeoJSON: \(error)")
        return []
      }
    }
    return []
  }
  
}

enum AirportSize: String, Comparable {
  case Small
  case Medium
  case Large
  
  // Establishing order among sizes for comparison
  static func < (lhs: AirportSize, rhs: AirportSize) -> Bool {
    // Define the hierarchy of sizes based on their raw values
    let sizeOrder: [AirportSize] = [.Large, .Medium, .Small]
    guard let lhsIndex = sizeOrder.firstIndex(of: lhs),
          let rhsIndex = sizeOrder.firstIndex(of: rhs) else {
      return false
    }
    return lhsIndex < rhsIndex
  }
}
