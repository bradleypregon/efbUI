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

struct SimConnectShip: Equatable {
  var coordinate: CLLocationCoordinate2D
  var altitude: Double
  var heading: Double
  var speed: Double
  var fs2ffid: Int
  var onGround: Bool?
  var registration: String?
  var lastUpdated: Date
}

@Observable
final class SimConnectShipObserver: Sendable {
  var ownship = CurrentValueSubject<SimConnectShip, Never>(.init(coordinate: CLLocationCoordinate2DMake(.zero, .zero), altitude: .zero, heading: .zero, speed: .zero, fs2ffid: .zero, lastUpdated: Date()))
  var trafficArray = CurrentValueSubject<[SimConnectShip], Never>([])
  var pruneTrafficArray = CurrentValueSubject<[SimConnectShip], Never>([])
}

class ServerStatus {
  @MainActor static let shared = ServerStatus()
  var status: Status = .stopped
  
  enum Status {
    case running, heartbeat, stopped
  }
}

// MARK: NWListener
final class ServerListener {
  var ship: SimConnectShipObserver
  private var port: NWEndpoint.Port = 49002
//  private let port: NWEndpoint.Port = 4000
  private var listener: NWListener?
  private var connection: NWConnection?
  private var listening: Bool = true
  private var timer: Timer?
  
  init(ship: SimConnectShipObserver) {
    self.ship = ship
    self.listener = try? NWListener(using: .udp, on: port)
    self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
      self.prune()
    }
  }
  
  func start() {
    self.listener?.stateUpdateHandler = { state in
      switch state {
      case .ready:
        print("Listener is ready")
        break
      case .failed, .cancelled:
        self.listening = false
        print("Listener did fail")
        self.stopListener()
      default:
        print("default triggered in listener state update")
        self.listening = true
        break
      }
    }
    
    self.listener?.newConnectionHandler = { connection in
      self.createConnection(connection: connection)
    }
    self.listener?.start(queue: DispatchQueue.global(qos: .userInitiated))
  }
  
  private func createConnection(connection: NWConnection) {
    self.connection = connection
    
    self.connection?.stateUpdateHandler = { state in
      switch state {
      case .ready:
        ServerStatus.shared.status = .running
        print("Connection ready to receive message")
        self.consumeData()
//        self.consumeDataGDL90()
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
      guard let stringData = String(data: receivedData, encoding: .utf8) else { return }
      let components = stringData.components(separatedBy: ",")
      
      if components[0] == "XGPSMSFS" {
        self.updateOwnship(components)
      } else if components[0] == "XTRAFFICMSFS" {
        self.updateTraffic(components)
      }
      
      self.consumeData()
    }
  }
  
  private func consumeDataGDL90() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 64000) { (data, _, isComplete, error) in
      
      guard let data = data else { return }
      // i think data.first is some hex value declaring message start?
      switch data.first {
      case 0x10: // Ownship Report
        print("Type ownship")
      default:
        print("unknown") // Unsupported message type
      }
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
    
    let ship = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed, fs2ffid: .zero, lastUpdated: Date())
    self.ship.ownship.send(ship)
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
    
    let plane: SimConnectShip = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed, fs2ffid: fs2ffID, onGround: onGround, registration: callsign, lastUpdated: Date())
    
    self.ship.trafficArray.send([plane])
    
  }
  
  func prune() {
    let now = Date()
    
    let oldShips = self.ship.trafficArray.value.filter({now.timeIntervalSince($0.lastUpdated) >= 30 })
    // $0.lastUpdated <= Date().addingTimeInterval(-30)
    if oldShips != [] {
      print("old ships: \(oldShips)")
    }
    
    self.ship.pruneTrafficArray.value.append(contentsOf: oldShips)
    self.ship.trafficArray.value.removeAll { self.ship.pruneTrafficArray.value.contains($0) }
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
