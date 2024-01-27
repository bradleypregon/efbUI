//
//  File.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/11/23.
//

import Foundation

// MARK: - AirportElement
struct Airport: Codable, Hashable, Identifiable {
  let id: String = UUID().uuidString
  let coordinates: Coordinates
  let properties: Properties
  
  enum CodingKeys: String, CodingKey {
    case coordinates, properties
  }
}

// MARK: - Coordinates
struct Coordinates: Codable, Hashable {
  let lat, long: Double
}

// MARK: - Properties
struct Properties: Codable, Hashable {
  let airportName: AirportName
  let cityServed, faa, iata, icao: String
  let size: Size
}

// MARK: - AirportName
struct AirportName: Codable, Hashable {
  let name: String
  let aka, fka: String?
}

enum Size: String, Codable, Hashable {
  case large = "Large"
  case medium = "Medium"
  case small = "Small"
}

