//
//  DBMan.swift
//  efbUI
//
//  Created by Bradley Pregon on 9/15/26.
//

import GRDB
import Foundation

@MainActor
@Observable
final class GRDBManager {
  let db: DatabasePool
  
  init() {
    let url = Bundle.main.url(forResource: "navdata", withExtension: "db") ?? URL(filePath: "")
    
    var config = Configuration()
    config.readonly = true
    
    do {
      self.db = try DatabasePool(path: url.path(percentEncoded: false), configuration: config)
    } catch {
      fatalError("Failed to initialize database: \(error)")
    }
  }
  
  func fetchRunways(for icao: String) async throws -> [RunwayTable] {
    try await db.read { db in
      try RunwayTable
        .filter(RunwayTable.Columns.airportIdentifier == icao)
        .fetchAll(db)
    }
  }
  
  func fetchAirport(by icao: String) async throws -> AirportTable? {
    try await db.read { db in
      try AirportTable
        .filter(AirportTable.Columns.airportIdentifier == icao)
        .fetchOne(db)
    }
  }
  
  // Search by name, identifier
  func searchAirports(searchText: String) async throws -> [AirportTable] {
    try await db.read { db in
      try AirportTable
        .filter(
          AirportTable.Columns.airportIdentifier.like("%\(searchText)%") ||
          AirportTable.Columns.airportName.like("%\(searchText)%")
        )
        .fetchAll(db)
    }
  }
  
  func fetchCommunications(for airportICAO: String) async throws -> [AirportCommunicationTable] {
    try await db.read { db in
      try AirportCommunicationTable
        .filter(AirportCommunicationTable.Columns.airportIdentifier == airportICAO)
        .fetchAll(db)
    }
    
  }

}
