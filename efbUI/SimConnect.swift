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

// XTRAFFICMSFS, fs2ff id?, lat, long, altitude, vertical speed, onGround 0 or 1, true heading, ground velocity, flight number or tail number

struct SimConnectShip: Identifiable {
  let id = UUID()
  
  var coordinate: CLLocationCoordinate2D
  var altitude: Double
  var heading: Double
  var speed: Double
  var fs2ffid: Int?
  var onGround: Bool?
  var registration: String?
}

@Observable
class SimConnectShipObserver {
  var ship: SimConnectShip? = nil
  var simConnectTraffic: [SimConnectShip] = []
  
//  var shipPublisher = PassthroughSubject<SimConnectShip, Never>()
//  private var cancellables = Set<AnyCancellable>()
//  init() {
//    shipPublisher
//      .sink { ship in
//        self.ship = ship
//      }.store(in: &cancellables)
//  }
  
}

final class SimConnectConnection {
  let simConnect: SimConnectShipObserver
  
  init(nwConnection: NWConnection, simConnect: SimConnectShipObserver) {
    self.nwConnection = nwConnection
    self.id = SimConnectConnection.nextID
    SimConnectConnection.nextID += 1
    self.simConnect = simConnect
  }
  
  private static var nextID: Int = 0
  
  let nwConnection: NWConnection
  let id: Int
  
  var didStopCallback: ((Error?) -> Void)? = nil
  
  func start() {
    print("connection \(self.id) will start")
    self.nwConnection.stateUpdateHandler = self.stateDidChange(to:)
    self.getData()
    self.nwConnection.start(queue: .main)
  }
  
  func send(data: Data) {
    self.nwConnection.send(content: data, completion: .contentProcessed( { error in
      if let error = error {
        self.connectionDidFail(error: error)
        return
      }
      print("connection \(self.id) did send, data: \(data as NSData)")
    }))
  }
  
  func stop() {
    print("connection \(self.id) will stop")
  }
  
  private func stateDidChange(to state: NWConnection.State) {
    switch state {
    case .setup:
      break
    case .waiting(let error):
      self.connectionDidFail(error: error)
    case .preparing:
      break
    case .ready:
      print("connection \(self.id) ready")
    case .failed(let error):
      self.connectionDidFail(error: error)
    case .cancelled:
      break
    default:
      break
    }
  }
  
  private func connectionDidFail(error: Error) {
    print("connection \(self.id) did fail, error: \(error)")
    self.stop(error: error)
  }
  
  private func connectionDidEnd() {
    print("connection \(self.id) did end")
    self.stop(error: nil)
  }
  
  private func stop(error: Error?) {
    self.nwConnection.stateUpdateHandler = nil
    self.nwConnection.cancel()
    if let didStopCallback = self.didStopCallback {
      self.didStopCallback = nil
      didStopCallback(error)
    }
  }
  
  // MARK: getData()
  func getData() {
    var buffer = Data()
    
    self.nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
      
      DispatchQueue.main.async {
        if let receivedData = data, !receivedData.isEmpty {
          buffer.append(receivedData)  // Accumulate incoming data in the buffer
        }
        
        // isComplete -> Process data
        if isComplete {
          if let stringData = String(data: buffer, encoding: .utf8) {
            let components = stringData.components(separatedBy: ",")
//            print("")
//            print(components)
//            print("")
            
            // XGPSMSFS, long, lat, alt, ground track, speed
            // MARK: Ownship update
            if components[0] == "XGPSMSFS" {
              let lat = Double(components[2])
              let long = Double(components[1])
              let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
              
              let altitude = Double(components[3]) ?? .zero
              let heading = Double(components[4]) ?? .zero
              let speed = Double(components[5]) ?? .zero
              
              let ship: SimConnectShip = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed)
              
              self.simConnect.ship = ship
//              self.simConnect.shipPublisher.send(ship)
            }
            
            // XTRAFFICMSFS, fs2ff id, lat, long, altitude, vertical speed, onGround (0 or 1), true heading, ground velocity, flight number or tail number
            if components[0] == "XTRAFFICMSFS" {
              let lat = Double(components[2])
              let long = Double(components[3])
              let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
              
              let fs2ffID = Int(components[1]) ?? .zero
              let altitude = Double(components[4]) ?? .zero
              let heading = Double(components[7]) ?? .zero
              let speed = Double(components[8]) ?? .zero
              let callsign = String(components[9])
              let onGround = components[6] == "1" ? true : false
              
              let plane: SimConnectShip = SimConnectShip(coordinate: coordinate, altitude: altitude, heading: heading, speed: speed, fs2ffid: fs2ffID, onGround: onGround, registration: callsign)
              
              // if traffic is in array, replace, otherwise, add
              // TODO: find better way of doing this?
              // How to handle planes no longer here? If the leave the game, their annotation will persist
              // Figure some kind of pruning function...
              //  maybe keep track of the traffic message with a timer
              //  if timer is x minutes after last message, remove plane
              for ship in self.simConnect.simConnectTraffic {
                if ship.fs2ffid == plane.fs2ffid {
                  self.simConnect.simConnectTraffic.removeAll(where: { $0.fs2ffid == plane.fs2ffid })
                }
              }
              self.simConnect.simConnectTraffic.append(plane)
//              self.simConnect.publisher.send(true)
            }
          }
          
          buffer.removeAll()  // Clear the buffer
          self.connectionDidEnd()
        } else if let error = error {
          self.connectionDidFail(error: error)
        } else {
          self.getData()  // Continue receiving more data
        }
      }
    }

  }
}

@Observable
final class SimConnectListener {
  var serverState: ServerState = .stopped
  
  enum ServerState {
    case connected, heartbeat, stopped
  }
}

final class SimConnectServer {
  @State var isRunning: Bool = false
  let simConnect: SimConnectShipObserver
  var simConnListener: SimConnectListener
  
  init(simConnect: SimConnectShipObserver, simConnListener: SimConnectListener) {
    self.simConnect = simConnect
    self.simConnListener = simConnListener
//    self.listener = try! NWListener(using: .udp, on: 4000)
    self.listener = try! NWListener(using: .udp, on: 49002)
    self.timer = DispatchSource.makeTimerSource(queue: .main)
  }
  
  let listener: NWListener
  let timer: DispatchSourceTimer
  
  func start() throws {
    print("Server will start")
    self.listener.stateUpdateHandler = self.stateDidChange(to:)
    self.listener.newConnectionHandler = self.didAccept(nwConnection:)
    self.listener.start(queue: .main)
    
    self.timer.setEventHandler(handler: self.heartbeat)
    self.timer.schedule(deadline: .now() + 5.0, repeating: 5.0)
    self.timer.activate()
    
    simConnListener.serverState = .heartbeat
    isRunning = true
  }
  
  func stateDidChange(to newState: NWListener.State) {
    switch newState {
    case .setup:
      break
    case .waiting:
      break
    case .ready:
      break
    case .failed(let error):
      print("server did fail, error: \(error)")
      self.stop()
    case .cancelled:
      break
    default:
      break
    }
  }
  
  private var connectionsByID: [Int: SimConnectConnection] = [:]
  
  private func didAccept(nwConnection: NWConnection) {
    let connection = SimConnectConnection(nwConnection: nwConnection, simConnect: simConnect)
    self.connectionsByID[connection.id] = connection
    
    connection.didStopCallback = { _ in
      self.connectionDidStop(connection)
    }
    connection.start()
    simConnListener.serverState = .connected
    print("Server opened connection \(connection.id)")
  }
  
  private func connectionDidStop(_ connection: SimConnectConnection) {
    self.connectionsByID.removeValue(forKey: connection.id)
    print("Server closed connection \(connection.id)")
  }
  
  func stop() {
    print("Server will stop")
    self.listener.stateUpdateHandler = nil
    self.listener.newConnectionHandler = nil
    self.listener.cancel()
    for connection in self.connectionsByID.values {
      connection.didStopCallback = nil
      connection.stop()
    }
    self.connectionsByID.removeAll()
    self.timer.cancel()
    
    simConnListener.serverState = .stopped
    isRunning = false
  }
  
  private func heartbeat() {
    let timestamp = Date()
    print("server heartbeat, timestamp: \(timestamp)")
    
    for connection in self.connectionsByID.values {
      let data = "heartbeat, connection: \(connection.id), timestamp: \(timestamp)\r\n"
      connection.send(data: Data(data.utf8))
    }
  }
  
}
