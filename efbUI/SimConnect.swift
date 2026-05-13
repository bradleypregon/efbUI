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

// MARK: - GDL90 Protocol Support
enum GDL90MessageType: UInt8 {
  case heartbeat = 0x00
  case initialization = 0x02
  case uplinkData = 0x07
  case heightAboveTerrain = 0x09
  case ownshipReport = 0x0A
  case ownshipGeometricAltitude = 0x0B
  case trafficReport = 0x14
  case basicReport = 0x1E
  case longReport = 0x1F
}

struct GDL90Message {
  static let flagByte: UInt8 = 0x7E
  static let controlEscapeByte: UInt8 = 0x7D
  
  let messageType: GDL90MessageType
  let data: Data
  
  static func decode(from data: Data) -> GDL90Message? {
    guard data.count >= 4 else { return nil } // Minimum: flag + type + crc + flag
    guard data.first == flagByte && data.last == flagByte else { return nil }
    
    // Remove flag bytes
    let messageData = data.dropFirst().dropLast()
    guard messageData.count >= 2 else { return nil }
    
    // Unescape the data
    let unescapedData = unescape(messageData)
    guard unescapedData.count >= 2 else { return nil }
    
    // Extract message type and payload
    guard let messageType = GDL90MessageType(rawValue: unescapedData[0]) else { return nil }
    let payload = unescapedData.dropFirst().dropLast(2) // Remove type and CRC
    
    return GDL90Message(messageType: messageType, data: Data(payload))
  }
  
  private static func unescape(_ data: Data) -> Data {
    var result = Data()
    var i = 0
    
    while i < data.count {
      if data[i] == controlEscapeByte && i + 1 < data.count {
        result.append(data[i + 1] ^ 0x20)
        i += 2
      } else {
        result.append(data[i])
        i += 1
      }
    }
    
    return result
  }
}

struct GDL90OwnshipReport {
  let latitude: Double
  let longitude: Double
  let altitude: Int // feet MSL
  let horizontalVelocity: Int // knots
  let verticalVelocity: Int // feet per minute
  let trackHeading: Int // degrees
  let onGround: Bool
  
  static func parse(from data: Data) -> GDL90OwnshipReport? {
    guard data.count >= 22 else { return nil }
    
    // Parse latitude (3 bytes, signed 24-bit)
    let latBytes = Array(data[1...3])
    let latRaw = (Int(latBytes[0]) << 16) | (Int(latBytes[1]) << 8) | Int(latBytes[2])
    let latitude = Double(latRaw > 0x7FFFFF ? latRaw - 0x1000000 : latRaw) * (180.0 / 8388608.0)
    
    // Parse longitude (3 bytes, signed 24-bit)
    let lonBytes = Array(data[4...6])
    let lonRaw = (Int(lonBytes[0]) << 16) | (Int(lonBytes[1]) << 8) | Int(lonBytes[2])
    let longitude = Double(lonRaw > 0x7FFFFF ? lonRaw - 0x1000000 : lonRaw) * (180.0 / 8388608.0)
    
    // Parse altitude (2 bytes)
    let altBytes = Array(data[7...8])
    let altRaw = (Int(altBytes[0]) << 4) | (Int(altBytes[1]) >> 4)
    let altitude = altRaw == 0xFFF ? 0 : (altRaw * 25) - 1000
    
    // Parse horizontal velocity (2 bytes)
    let hvBytes = Array(data[10...11])
    let horizontalVelocity = ((Int(hvBytes[0]) & 0x0F) << 8) | Int(hvBytes[1])
    
    // Parse vertical velocity (2 bytes)
    let vvBytes = Array(data[12...13])
    let vvRaw = ((Int(vvBytes[0]) & 0x0F) << 8) | Int(vvBytes[1])
    let verticalVelocity = vvRaw == 0x800 ? 0 : (vvRaw > 0x7FF ? vvRaw - 0x1000 : vvRaw) * 64
    
    // Parse track/heading
    let trackByte = data[14]
    let trackHeading = Int(trackByte) * 360 / 256
    
    // Parse status flags
    let statusByte = data[9]
    let onGround = (statusByte & 0x01) == 0x01
    
    return GDL90OwnshipReport(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      horizontalVelocity: horizontalVelocity,
      verticalVelocity: verticalVelocity,
      trackHeading: trackHeading,
      onGround: onGround
    )
  }
}

struct GDL90TrafficReport {
  let latitude: Double
  let longitude: Double
  let altitude: Int
  let horizontalVelocity: Int
  let verticalVelocity: Int
  let trackHeading: Int
  let callsign: String
  let onGround: Bool
  let aircraftType: Int
  
  static func parse(from data: Data) -> GDL90TrafficReport? {
    guard data.count >= 24 else { return nil }
    
    // Parse similar to ownship report but with callsign
    let latBytes = Array(data[2...4])
    let latRaw = (Int(latBytes[0]) << 16) | (Int(latBytes[1]) << 8) | Int(latBytes[2])
    let latitude = Double(latRaw > 0x7FFFFF ? latRaw - 0x1000000 : latRaw) * (180.0 / 8388608.0)
    
    let lonBytes = Array(data[5...7])
    let lonRaw = (Int(lonBytes[0]) << 16) | (Int(lonBytes[1]) << 8) | Int(lonBytes[2])
    let longitude = Double(lonRaw > 0x7FFFFF ? lonRaw - 0x1000000 : lonRaw) * (180.0 / 8388608.0)
    
    let altBytes = Array(data[8...9])
    let altRaw = (Int(altBytes[0]) << 4) | (Int(altBytes[1]) >> 4)
    let altitude = altRaw == 0xFFF ? 0 : (altRaw * 25) - 1000
    
    let hvBytes = Array(data[11...12])
    let horizontalVelocity = ((Int(hvBytes[0]) & 0x0F) << 8) | Int(hvBytes[1])
    
    let vvBytes = Array(data[13...14])
    let vvRaw = ((Int(vvBytes[0]) & 0x0F) << 8) | Int(vvBytes[1])
    let verticalVelocity = vvRaw == 0x800 ? 0 : (vvRaw > 0x7FF ? vvRaw - 0x1000 : vvRaw) * 64
    
    let trackByte = data[15]
    let trackHeading = Int(trackByte) * 360 / 256
    
    let statusByte = data[10]
    let onGround = (statusByte & 0x01) == 0x01
    let aircraftType = Int(statusByte >> 4) & 0x0F
    
    // Parse callsign (8 bytes)
    let callsignData = data[16..<min(24, data.count)]
    let callsign = String(data: callsignData, encoding: .ascii)?
      .trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "\0"))) ?? ""
    
    return GDL90TrafficReport(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      horizontalVelocity: horizontalVelocity,
      verticalVelocity: verticalVelocity,
      trackHeading: trackHeading,
      callsign: callsign,
      onGround: onGround,
      aircraftType: aircraftType
    )
  }
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
  enum ProtocolType {
    case textBased // XGPSMSFS, XTRAFFICMSFS
    case gdl90     // Binary GDL90 protocol
  }
  
  var ship: SimConnectShipObserver
  private var port: NWEndpoint.Port = 49002 // 4000 for gdl90
  private var listener: NWListener?
  private var heartbeatConnection: NWConnection?
  private var connection: NWConnection?
  private var listening: Bool = true
  
  // Protocol selection
  var protocolType: ProtocolType = .textBased
  
  private var timer: DispatchSourceTimer
  private var lastHeartbeat: Date = Date.distantPast
  private var lastPrune: Date = Date.distantPast
  
  init(ship: SimConnectShipObserver, protocolType: ProtocolType = .textBased) {
    self.ship = ship
    self.protocolType = protocolType
    
    // Set port based on protocol type
    self.port = protocolType == .gdl90 ? 4000 : 49002
    
    self.listener = try? NWListener(using: .udp, on: port)
    self.timer = DispatchSource.makeTimerSource(queue: .main)
    
    // Set up heartbeat connection for broadcasting
    let endpoint = NWEndpoint.hostPort(host: .ipv4(.broadcast), port: 63093)
    let parameters = NWParameters.udp
    parameters.allowLocalEndpointReuse = true
    
    self.heartbeatConnection = NWConnection(to: endpoint, using: parameters)
    self.heartbeatConnection?.start(queue: .global())
  }
  
  func switchProtocol(to newProtocol: ProtocolType) {
    guard newProtocol != self.protocolType else { return }
    
    // Stop current listener
    stop()
    
    // Update protocol and port
    self.protocolType = newProtocol
    self.port = newProtocol == .gdl90 ? 4000 : 49002
    
    // Create new listener with new port
    self.listener = try? NWListener(using: .udp, on: port)
    
    // Restart
    start()
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
        
        // Heartbeat every 5 seconds
        if now.timeIntervalSince(self.lastHeartbeat) >= 5 {
          self.lastHeartbeat = now
          if let heartbeatConnection = self.heartbeatConnection {
            ServerStatus.shared.status = .heartbeat
            self.heartbeatTest(conn: heartbeatConnection)
          } else {
            print("Issue with heartbeat connection - attempting to recreate")
            let endpoint = NWEndpoint.hostPort(host: .ipv4(.broadcast), port: 63093)
            let parameters = NWParameters.udp
            parameters.allowLocalEndpointReuse = true
            self.heartbeatConnection = NWConnection(to: endpoint, using: parameters)
            self.heartbeatConnection?.start(queue: .global())
          }
        }
        
        // Prune traffic every 10 seconds
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
        switch state {
        case .ready:
          ServerStatus.shared.status = .running
          print("Connection ready to receive message")
          switch self.protocolType {
          case .textBased:
            self.consumeData()
          case .gdl90:
            self.consumeDataGDL90()
          }
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
        if let error = error {
          print("NWError received in \(#function): \(error)")
        }
        guard let receivedData = data, !receivedData.isEmpty, isComplete else { return }
        
        // Auto-detect protocol if needed
        if self.protocolType == .textBased {
          // Check if it's actually GDL90 data (starts with 0x7E)
          if receivedData.first == 0x7E {
            print("Detected GDL90 protocol, switching...")
            self.protocolType = .gdl90
            self.processGDL90Data(receivedData)
            self.consumeDataGDL90() // Switch to GDL90 consumption
            return
          }
        }
        
        // Process as text-based protocol
        guard let stringData = String(data: receivedData, encoding: .utf8) else { 
          print("Failed to decode text data, length: \(receivedData.count)")
          self.consumeData()
          return 
        }
        
        print("Received: \(stringData)")
        let components = stringData.components(separatedBy: ",")
        if components[0] == "XGPSMSFS" {
          self.updateOwnship(components)
        } else if components[0] == "XTRAFFICMSFS" {
          self.updateTraffic(components)
        } else {
          print("Unknown message type: \(components[0])")
        }
        self.consumeData()
      }
    }
  }
  
  private func consumeDataGDL90() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 64000) { [self] (data, _, isComplete, error) in
      Task { @MainActor in
        if let error = error {
          print("NWError received in GDL90 \(#function): \(error)")
        }
        guard let receivedData = data, !receivedData.isEmpty else { 
          self.consumeDataGDL90() // Continue listening
          return 
        }
        
        print("Received GDL90 data: \(receivedData.count) bytes")
        // Process GDL90 messages
        self.processGDL90Data(receivedData)
        self.consumeDataGDL90()
      }
    }
  }
  
  private func processGDL90Data(_ data: Data) {
    // GDL90 messages start and end with 0x7E flag bytes
    var messageStart = 0
    
    while messageStart < data.count {
      // Find the start of the next message
      guard let startIndex = data[messageStart...].firstIndex(of: GDL90Message.flagByte) else {
        break
      }
      
      // Find the end of the message
      let searchStart = data.index(after: startIndex)
      guard searchStart < data.endIndex,
            let endIndex = data[searchStart...].firstIndex(of: GDL90Message.flagByte) else {
        break
      }
      
      // Extract the complete message including flag bytes
      let messageData = data[startIndex...endIndex]
      
      // Decode and process the message
      if let message = GDL90Message.decode(from: Data(messageData)) {
        self.handleGDL90Message(message)
      }
      
      // Move to the next potential message
      messageStart = data.distance(from: data.startIndex, to: endIndex) + 1
    }
  }
  
  private func handleGDL90Message(_ message: GDL90Message) {
    switch message.messageType {
    case .ownshipReport:
      if let ownshipReport = GDL90OwnshipReport.parse(from: message.data) {
        updateOwnshipFromGDL90(ownshipReport)
      }
    case .trafficReport:
      if let trafficReport = GDL90TrafficReport.parse(from: message.data) {
        updateTrafficFromGDL90(trafficReport)
      }
    case .heartbeat:
      print("GDL90 Heartbeat received")
    default:
      print("Unhandled GDL90 message type: \(message.messageType)")
    }
  }
  
  private func updateOwnshipFromGDL90(_ report: GDL90OwnshipReport) {
    let coordinate = CLLocationCoordinate2D(latitude: report.latitude, longitude: report.longitude)
    
    let ship = SimConnectShip(
      coordinate: coordinate,
      altitude: Double(report.altitude),
      heading: Double(report.trackHeading),
      speed: Double(report.horizontalVelocity),
      fs2ffid: 0,
      onGround: report.onGround,
      lastUpdated: Date()
    )
    
    self.ship.ownship.send(ship)
  }
  
  private func updateTrafficFromGDL90(_ report: GDL90TrafficReport) {
    let coordinate = CLLocationCoordinate2D(latitude: report.latitude, longitude: report.longitude)
    
    let plane = SimConnectShip(
      coordinate: coordinate,
      altitude: Double(report.altitude),
      heading: Double(report.trackHeading),
      speed: Double(report.horizontalVelocity),
      fs2ffid: report.aircraftType, // Using aircraft type as ID for now
      onGround: report.onGround,
      registration: report.callsign.isEmpty ? nil : report.callsign,
      lastUpdated: Date()
    )
    
    self.ship.trafficArray.send([plane])
  }
  
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
    print("Sending FS2FF heartbeat")
    
    // fs2ff expects exactly this JSON structure
    struct HeartbeatMessage: Codable {
      var App: String = "ForeFlight"
    }
    
    do {
      let data = try JSONEncoder().encode(HeartbeatMessage())
      print("Heartbeat data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
      
      conn.send(content: data, completion: .contentProcessed { error in
        if let error {
          print("FS2FFService: Heartbeat send error: \(error)")
        } else {
          print("Heartbeat sent successfully")
        }
      })
    } catch {
      print("Error encoding heartbeat: \(error)")
    }
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
    self.heartbeatConnection?.cancel()
    self.heartbeatConnection = nil
    ServerStatus.shared.status = .stopped
  }
}



