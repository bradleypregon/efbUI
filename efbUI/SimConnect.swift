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
import SystemConfiguration.CaptiveNetwork

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

// MARK: ServerListener
@MainActor
final class ServerListener {
  var ship: SimConnectShipObserver
  private var port: NWEndpoint.Port = 49002 // 4000 for gdl90
  private var listener: NWListener?
  private var heartbeatConnection: NWConnection?
  private var connection: NWConnection?
  private var listening: Bool = true
  
  private var timer: DispatchSourceTimer
  private var lastHeartbeat: Date = Date.distantPast
  private var lastPrune: Date = Date.distantPast
  
  init(ship: SimConnectShipObserver) {
    self.ship = ship
    self.listener = try? NWListener(using: .udp, on: port)
    self.timer = DispatchSource.makeTimerSource(queue: .main)
    
    let endpoint = NWEndpoint.hostPort(host: .ipv4(.broadcast), port: 63093)
    self.heartbeatConnection = NWConnection(to: endpoint, using: .udp)
    self.heartbeatConnection?.start(queue: .global())
  }
  
  func start() {
    self.listener?.stateUpdateHandler = { [self] state in
      Task { @MainActor in
        switch state {
        case .ready:
          print("Listener is ready")
        case .failed, .cancelled:
          self.listening = false
          print("Listener did fail")
          self.stopListener()
        default:
          print("default triggered in listener state update")
          self.listening = true
        }
      }
    }
    self.listener?.newConnectionHandler = { [self] connection in
      Task { @MainActor in
        self.createConnection(connection: connection)
      }
    }
    self.listener?.start(queue: DispatchQueue.global(qos: .userInitiated))
    
    self.timer.setEventHandler { [self] in
      Task { @MainActor in
        let now = Date()
        
        // Heartbeat 5 seconds
        if now.timeIntervalSince(self.lastHeartbeat) >= 5 {
          self.lastHeartbeat = now
          if let heartbeatConnection {
            self.heartbeatTest(conn: heartbeatConnection)
          } else {
            print("Issue with heartbeat connection")
          }
        }
        
        // Prune 10 seconds
        if now.timeIntervalSince(self.lastPrune) >= 10 {
          self.lastPrune = now
          self.prune()
        }
      }
    }
    
    self.timer.schedule(deadline: .now() + 2.5, repeating: 2.5)
    self.timer.activate()
  }
  
  private func createConnection(connection: NWConnection) {
    self.connection = connection
    
    self.connection?.stateUpdateHandler = { [self] state in
      Task { @MainActor in
//        guard let self else { return }
        switch state {
        case .ready:
          ServerStatus.shared.status = .running
          print("Connection ready to receive message")
          self.consumeData() // self.consumeDataGDL90
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
    }
    
    self.connection?.start(queue: .global())
  }
  
  private func consumeData() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 64000) { [self] (data, _, isComplete, error) in
      Task { @MainActor in
//        guard let self else { return }
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
  }
  
  // Ignore for now
  /*
  private func consumeDataGDL90() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 64000) { [weak self] (data, _, isComplete, error) in
      Task { @MainActor in
        guard let self else { return }
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
  }
  */
  
  // XGPSMSFS, long, lat, alt, ground track, speed
  private func updateOwnship(_ components: [String]) {
    let lat = Double(components[2])
    let long = Double(components[1])
    let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
    let altitude = Double(components[3]) ?? .zero
    let heading = Double(components[4]) ?? .zero
    let speed = Double(components[5]) ?? .zero
    
    let ship = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed, fs2ffid: .zero, lastUpdated: Date())
    self.ship.ownship.send(ship)
  }
  
  // XTRAFFICMSFS, fs2ff id, lat, long, altitude, vertical speed, onGround (0 or 1), true heading, ground velocity, flight number or tail number
  private func updateTraffic(_ components: [String]) {
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
  
  // Prune items from trafficArray that have not received an update for at least 30 seconds
  func prune() {
    let oldShips = self.ship.trafficArray.value.filter({Date().timeIntervalSince($0.lastUpdated) >= 30 })
    if oldShips == [] { return }
    
    print("Old ships: \(oldShips)")
    
    self.ship.pruneTrafficArray.value.append(contentsOf: oldShips)
    self.ship.trafficArray.value.removeAll { self.ship.pruneTrafficArray.value.contains($0) }
  }
  
  private func heartbeatTest(conn: NWConnection) {
    print("heartbeat")
    let jsonString = #"{"App":"ForeFlight"}"#
    guard let data = jsonString.data(using: .utf8) else { return }
    print(data)
    print(conn)
    conn.send(content: data, completion: .contentProcessed { error in
      if let error {
        print("FS2FFService: Heartbeat send error: \(error)")
        conn.cancel()
      }
    })
  }
  
  private func heartbeat() {
    struct Heartbeat: Codable {
      let ip: String
      let port: UInt16
    }
    let heartbeat = Heartbeat(ip: getIP(), port: 49002)
    
    do {
      let data = try JSONEncoder().encode(heartbeat)
      let endpoint = NWEndpoint.hostPort(host: .ipv4(.broadcast), port: 63093)
      let udpConn = NWConnection(to: endpoint, using: .udp)
      udpConn.start(queue: .global())
      udpConn.send(content: data, completion: .contentProcessed { error in
        if let error = error {
          print("Heartbeat send error: \(error)")
        }
        udpConn.cancel()
      })
    } catch {
      print("Error encoding heartbeat")
    }
  }
  
  private func getIP() -> String {
    var address: String = ""
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        let interface = ptr?.pointee
        let addrFamily = interface?.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) {
          if let name = String(validatingUTF8: interface!.ifa_name), name == "en0" {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(interface!.ifa_addr, socklen_t(interface!.ifa_addr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, socklen_t(0), NI_NUMERICHOST) == 0 {
              address = String(cString: hostname)
            }
          }
        }
        ptr = ptr?.pointee.ifa_next
      }
      freeifaddrs(ifaddr)
    }
    
    return address
  }
  
  private func stopListener() {
    self.listener?.stateUpdateHandler = nil
    self.listener?.newConnectionHandler = nil
    self.listener?.cancel()
  }
  
  private func stopConnection() {
    self.connection?.cancel()
    self.connection?.stateUpdateHandler = nil
  }
  
  func stop() {
    self.timer.cancel()
    stopListener()
    stopConnection()
  }
}



