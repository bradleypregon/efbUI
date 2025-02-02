//
//  SQLManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/20/25.
//

import Foundation
import GRDB

final class SQLManager {
  var queue: DatabaseQueue? = nil
  
  init() {
    do {
      self.queue = try DatabaseQueue(path: "")
    } catch let error {
      queue = nil
      print(error)
    }
  }
  
  func fetchAirports() -> [AirportTable] {
    guard let db = queue else { return [] }
    
    return []
  }
  
  deinit {
    self.queue = nil
  }
}
