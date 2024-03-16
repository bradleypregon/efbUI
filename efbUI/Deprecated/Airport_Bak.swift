//
//  File.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/11/23.
//

//import Foundation
//import Observation

// MARK: - AirportElement
//@Observable
//class Airport: Decodable, Identifiable, Hashable, Equatable {
//  let id = UUID()
//  let coordinates: Coordinates
//  let properties: Properties
//  var visible: Bool = false
//  
//  enum CodingKeys: String, CodingKey {
//    case coordinates, properties
//  }
//}
//
//// MARK: - Coordinates
//class Coordinates: Decodable, Hashable {
//  let lat, long: Double
//}
//
//// MARK: - Properties
//class Properties: Decodable, Hashable {
//  let airportName: AirportName
//  let cityServed, faa, iata, icao: String
//  let size: Size
//  
//  enum Size: String, Decodable, Hashable {
//    case large = "Large"
//    case medium = "Medium"
//    case small = "Small"
//  }
//}
//
//// MARK: - AirportName
//class AirportName: Decodable, Hashable {
//  let name: String
//  let aka, fka: String?
//}
//
//
//
//extension Hashable where Self: AnyObject {
//  func hash(into hasher: inout Hasher) {
//    hasher.combine(ObjectIdentifier(self))
//  }
//}
//
//extension Equatable where Self: AnyObject {
//  static func == (lhs:Self, rhs:Self) -> Bool {
//    return lhs===rhs
//  }
//}
