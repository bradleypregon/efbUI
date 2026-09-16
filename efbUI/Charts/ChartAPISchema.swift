//
//  AirportChartAPISchema.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/17/23.
//

import Foundation

// MARK: - Welcome
struct ChartAPISchema: Decodable {
  let airportData: ChartAPIAirportDataSchema
  let charts: ChartAPIChartsSchema
  
  enum CodingKeys: String, CodingKey {
    case airportData = "airport_data"
    case charts
  }
}

// MARK: - AirportData
struct ChartAPIAirportDataSchema: Decodable {
  let city, stateAbbr, stateFull, country: String
  let icaoIdent, faaIdent, airportName: String
  let isMilitary: Bool
  
  enum CodingKeys: String, CodingKey {
    case city
    case stateAbbr = "state_abbr"
    case stateFull = "state_full"
    case country
    case icaoIdent = "icao_ident"
    case faaIdent = "faa_ident"
    case airportName = "airport_name"
    case isMilitary = "is_military"
  }
}

// MARK: - AirportChartAPIChartsSchema
struct ChartAPIChartsSchema: Decodable, Identifiable {
  let id: String = UUID().uuidString
  let airportDiagram, general, departure, arrival, approach: [ChartAPIChartSchema]
  
  enum CodingKeys: String, CodingKey {
    case airportDiagram = "airport_diagram"
    case general, departure, arrival, approach
  }
}

// MARK: - AirportChartAPIChartSchema
struct ChartAPIChartSchema: Decodable, Identifiable {
  let id: String = UUID().uuidString
  let chartName, chartSequence, pdfName: String
  let pdfURL: String
  let didChange: Bool
  let changePDFName: String?
  let changePDFURL: String?
  
  enum CodingKeys: String, CodingKey {
    case chartName = "chart_name"
    case chartSequence = "chart_sequence"
    case pdfName = "pdf_name"
    case pdfURL = "pdf_url"
    case didChange = "did_change"
    case changePDFName = "change_pdf_name"
    case changePDFURL = "change_pdf_url"
  }
}

// MARK: - Arrival
/*
struct AirportChartAPIArrival: Codable {
  let chartName, chartSequence, pdfName: String
  let pdfURL: String
  let didChange: Bool
  
  enum CodingKeys: String, CodingKey {
    case chartName = "chart_name"
    case chartSequence = "chart_sequence"
    case pdfName = "pdf_name"
    case pdfURL = "pdf_url"
    case didChange = "did_change"
  }
}
*/
