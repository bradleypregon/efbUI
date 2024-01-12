//
//  AirportAnnotation.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/8/22.
//

import CoreLocation
import MapKit

class AirportAnnotation: NSObject, Identifiable, MKAnnotation {
  // TODO: Make unique?
  var id = UUID()
  
  var coordinate: CLLocationCoordinate2D
  let properties: Properties
  
  init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, properties: Properties) {
    self.id = id
    self.coordinate = coordinate
    self.properties = properties
  }
  
}
