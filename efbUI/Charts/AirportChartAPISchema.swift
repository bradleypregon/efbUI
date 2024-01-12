//
//  AirportChartAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

struct AirportChartAPISchema: Decodable {
  let airport: String
  let general, dp, star, capp: [AirportDetail]
  
  enum CodingKeys: String, CodingKey {
    case airport
    case general = "General"
    case dp = "DP"
    case star = "STAR"
    case capp = "CAPP"
  }
  
  init(from decoder: Decoder) throws {
    
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    general = try container.decode([AirportDetail].self, forKey: CodingKeys.general)
    dp = try container.decode([AirportDetail].self, forKey: CodingKeys.dp)
    star = try container.decode([AirportDetail].self, forKey: CodingKeys.star)
    capp = try container.decode([AirportDetail].self, forKey: CodingKeys.capp)
    
    airport = container.codingPath.first!.stringValue
  }
}

struct AirportDetail: Decodable, Equatable {
  let state: String
  let stateFull: String
  let city: String
  let volume: String
  let airportName: String
  let military: String
  let faaIdent: String
  let icaoIdent: String
  let chartSeq: String
  let chartCode: String
  let chartName: String
  let pdfName: String
  let pdfPath: String
  
  enum CodingKeys: String, CodingKey {
    case state
    case stateFull = "state_full"
    case city
    case volume
    case airportName = "airport_name"
    case military
    case faaIdent = "faa_ident"
    case icaoIdent = "icao_ident"
    case chartSeq = "chart_seq"
    case chartCode = "chart_code"
    case chartName = "chart_name"
    case pdfName = "pdf_name"
    case pdfPath = "pdf_path"
  }
}

struct DecodedArray<T: Decodable>: Decodable {
  
  typealias DecodedArrayType = [T]
  
  private var array: DecodedArrayType
  // Define DynamicCodingKeys type needed for creating decoding container from JSONDecoder
  private struct DynamicCodingKeys: CodingKey {
    
    // Use for string-keyed dictionary
    var stringValue: String
    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    
    // Use for integer-keyed dictionary
    var intValue: Int?
    init?(intValue: Int) {
      // We are not using this, thus just return nil
      return nil
    }
  }
  
  init(from decoder: Decoder) throws {
    
    // Create decoding container using DynamicCodingKeys
    // The container will contain all the JSON first level key
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
    
    var tempArray = DecodedArrayType()
    
    // Loop through each keys in container
    for key in container.allKeys {
      
      // Decode T using key & keep decoded T object in tempArray
      let decodedObject = try container.decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
      tempArray.append(decodedObject)
    }
    
    // Finish decoding all T objects. Thus assign tempArray to array.
    array = tempArray
  }
}

// Transform DecodedArray into custom collection
extension DecodedArray: Collection {
  
  // Required nested types, that tell Swift what our collection contains
  typealias Index = DecodedArrayType.Index
  typealias Element = DecodedArrayType.Element
  // The upper and lower bounds of the collection, used in iterations
  var startIndex: Index { return array.startIndex }
  var endIndex: Index { return array.endIndex }
  
  // Required subscript, based on a dictionary index
  subscript(index: Index) -> Element {
    get { return array[index] }
  }
  
  // Method that returns the next index when iterating
  func index(after i: Index) -> Index {
    return array.index(after: i)
  }
}
