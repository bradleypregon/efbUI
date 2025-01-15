//
//  AirportChartAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

struct AirportChartAPISchema: Decodable {
  let general, dp, star, capp: [Chart]
  
  enum CodingKeys: String, CodingKey {
    case general = "General"
    case dp = "DP"
    case star = "STAR"
    case capp = "CAPP"
  }
}

struct Chart: Decodable, Equatable, Identifiable {
  var id: String = UUID().uuidString
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
