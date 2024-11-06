//
//  SimConnect.swift
//  EFB
//
//  Created by Bradley Pregon on 10/31/21.
//

import SwiftUI
import Network
import CoreLocation
import Combine
import Observation

struct SimConnectShip: Identifiable, Equatable {
  let id = UUID()
  
  var coordinate: CLLocationCoordinate2D
  var altitude: Double
  var heading: Double
  var speed: Double
  var fs2ffid: Int?
  var onGround: Bool?
  var registration: String?
  var lastUpdated: Int?
}

@Observable
final class SimConnectShipObserver {
  var ownship: SimConnectShip = .init(coordinate: .init(latitude: .zero, longitude: .zero), altitude: .zero, heading: .zero, speed: .zero)
  var traffic: [String: SimConnectShip] = [:]
  var pruneTraffic: [String: SimConnectShip] = [:]
}

class ServerStatus {
  static let shared = ServerStatus()
  var status: Status = .stopped
  
  enum Status {
    case running, heartbeat, stopped
  }
}

// MARK: NWListener
final class ServerListener {
  var ship: SimConnectShipObserver
  private let port: NWEndpoint.Port = 49002
  private var listener: NWListener?
  private var connection: NWConnection?
  private var listening: Bool = true
  
  init(ship: SimConnectShipObserver) {
    self.ship = ship
    self.listener = try? NWListener(using: .udp, on: port)
  }
  
  func start() {
    self.listener?.stateUpdateHandler = { [self] state in
      switch state {
      case .ready:
        print("Listener is ready")
        break
      case .failed, .cancelled:
        listening = false
        print("Listener did fail")
        stopListener()
      default:
        print("default triggered in listener state update")
        listening = true
        break
      }
    }
    
    self.listener?.newConnectionHandler = { [self] connection in
      createConnection(connection: connection)
    }
    self.listener?.start(queue: DispatchQueue.global(qos: .userInitiated))
  }
  
  private func createConnection(connection: NWConnection) {
    self.connection = connection
    
    self.connection?.stateUpdateHandler = { [self] state in
      switch state {
      case .ready:
        ServerStatus.shared.status = .running
        print("Connection ready to receive message")
        self.consumeData()
      case .cancelled, .failed:
        ServerStatus.shared.status = .stopped
        self.listening = false
        print("Connection stopped")
        self.listener?.cancel()
      default:
        print("default triggered in connection createConnection")
        print("Connection waiting to receive message")
      }
    }
    
    self.connection?.start(queue: .global())
  }
  
  private func consumeData() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 64000) { (data, _, isComplete, error) in
      
        if let error = error {
          print("NWError received in \(#function): \(error)")
        }
        guard let receivedData = data, !receivedData.isEmpty, isComplete else { return }
        
        if let stringData = String(data: receivedData, encoding: .utf8) {
          let components = stringData.components(separatedBy: ",")
          
          // MARK: Ownship update
          if components[0] == "XGPSMSFS" {
            self.updateOwnship(components)
          }
          if components[0] == "XTRAFFICMSFS" {
            self.updateTraffic(components)
          }
        }
        
        self.consumeData()
    }
  }
  
  private func updateOwnship(_ components: [String]) {
    /// XGPSMSFS, long, lat, alt, ground track, speed
    let lat = Double(components[2])
    let long = Double(components[1])
    let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
    let altitude = Double(components[3]) ?? .zero
    let heading = Double(components[4]) ?? .zero
    let speed = Double(components[5]) ?? .zero
    
    self.ship.ownship.coordinate = coordinate
    self.ship.ownship.altitude = altitude
    self.ship.ownship.heading = heading
    self.ship.ownship.speed = speed
  }
  
  private func updateTraffic(_ components: [String]) {
    /// XTRAFFICMSFS, fs2ff id, lat, long, altitude, vertical speed, onGround (0 or 1), true heading, ground velocity, flight number or tail number
    let lat = Double(components[2])
    let long = Double(components[3])
    let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
    
    let fs2ffID = Int(components[1]) ?? .zero
    let altitude = Double(components[4]) ?? .zero
    let heading = Double(components[7]) ?? .zero
    let speed = Double(components[8]) ?? .zero
    let callsign = String(components[9])
    let onGround = components[6] == "1" ? true : false
    
    let plane: SimConnectShip = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed, fs2ffid: fs2ffID, onGround: onGround, registration: callsign, lastUpdated: Int(Date().timeIntervalSinceNow))
    
    // How to handle planes no longer here? If the leave the game, their annotation will persist
    // Add timestamp property to SimConnectShip
    // for ship in traffic hashmap
    //  if ship.timestamp is greater than now minus 1 minute
    //    add ship to 'prune' hash of ships, remove from traffic hashmap
    //    or, just remove it from traffic hashmap?
    //      how will MapScreen know to remove the layer
    
//    for ship in self.ship.traffic {
//      if ship.fs2ffid == plane.fs2ffid {
//        self.ship.traffic.removeAll(where: { $0.fs2ffid == plane.fs2ffid })
//      }
//    }
//    self.ship.traffic.append(plane)
    
    self.ship.traffic[String(describing: plane.fs2ffid)] = plane
    for (ffid, traffic) in self.ship.traffic {
      guard let trafficTimestamp = traffic.lastUpdated else { return }
      if trafficTimestamp < Int(Date().timeIntervalSinceNow) - 60 {
        self.ship.pruneTraffic[ffid] = traffic
        self.ship.traffic.removeValue(forKey: ffid)
      }
    }
  }
  
  private func stopListener() {
    print("Server will stop")
    self.listener?.stateUpdateHandler = nil
    self.listener?.newConnectionHandler = nil
    self.listener?.cancel()
  }
  
  private func stopConnection() {
    self.connection?.cancel()
    self.connection?.stateUpdateHandler = nil
  }
  
  func stop() {
    stopListener()
    stopConnection()
  }
  
}
