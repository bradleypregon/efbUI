//
//  AirporSchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/16/24.
//

import Foundation

class AirportSchema: Decodable, Identifiable {
  var id: String = UUID().uuidString
  let lat: Double
  let long: Double
  let name: String
  let city: String
  let country: String
  let countryCode: String
  let icao: String
  let size: AirportSizeSchema
  
  enum CodingKeys: String, CodingKey {
    case lat, long, name, city, country, countryCode, icao, size
  }
}

enum AirportSizeSchema: String, Decodable {
  case large = "Large"
  case medium = "Medium"
  case small = "Small"
}

struct AirportGeoSchema: Decodable {
  let type: String
  let features: [AirportSchemaFeature]
  
  enum CodingKeys: String, CodingKey {
    case type, features
  }
}

struct AirportSchemaFeature: Decodable, Identifiable {
  var id: String = UUID().uuidString
  let type: String
  let coordinates: [Double]
  let properties: AirportSchemaFeatureProperties
  
  enum CodingKeys: String, CodingKey {
    case type, coordinates, properties
  }
}

struct AirportSchemaFeatureProperties: Decodable {
  let name: String
  let city: String
  let country: String
  let countryCode: String
  let icao: String
  let size: AirportSizeSchema
  
  enum CodingKeys: String, CodingKey {
    case name, city, country, countryCode, icao, size
  }
}
