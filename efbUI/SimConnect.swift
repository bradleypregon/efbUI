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

struct SimConnectShipEvent {
  var coordinate: CLLocationCoordinate2D
  var altitude: Double
  var heading: Double
  var speed: Double
  var registration: String?
}

// XTRAFFICFLIGHT Events, _, Long, Lat, Height, _, _, Heading, _, Registration
// XATTFlight Events, _, _, _
// XGPSFlight Events, Longitude, Latitude, Height in meters, Heading, Speed (assume km/s?)

@Observable
class SimConnectShips {
  static let shared = SimConnectShips()
  var simConnectShip: SimConnectShipEvent? = nil
  private var cancellables = Set<AnyCancellable>()
  
  // publisher for changes
  var didChange: Bool = false
  let publisher = PassthroughSubject<Bool, Never>()
  init() {
    publisher.sink { temp in
      self.didChange = true
      self.didChange = false
    }.store(in: &cancellables)
  }
  
}

final class SimConnectConnection {
  let simConnect: SimConnectShips
  
  init(nwConnection: NWConnection, simConnect: SimConnectShips) {
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
    var simConnectShip: SimConnectShipEvent = SimConnectShipEvent(coordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), altitude: .zero, heading: .zero, speed: .zero)
    
    self.nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
      
      DispatchQueue.main.async {
        if let receivedData = data, !receivedData.isEmpty {
          buffer.append(receivedData)  // Accumulate incoming data in the buffer
        }
        
        if isComplete {
          // Process the accumulated data when a complete message is received
          if let stringData = String(data: buffer, encoding: .utf8) {
            let components = stringData.components(separatedBy: ",")
            
            if components[0] == "XGPSFlight Events" {
              let lat = Double(components[2])
              let long = Double(components[1])
              let coordinate = CLLocationCoordinate2D(latitude: lat ?? .zero, longitude: long ?? .zero)
              
              let altitude = Double(components[3]) ?? .zero
              let heading = Double(components[4]) ?? .zero
              let speed = Double(components[5]) ?? .zero
              
              simConnectShip.coordinate = coordinate
              simConnectShip.altitude = altitude
              simConnectShip.heading = heading
              simConnectShip.speed = speed
              
              self.simConnect.simConnectShip = simConnectShip
              self.simConnect.publisher.send(true)
//              self.simConnect.gpsEvent = setGPSEvent(components: components)
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
    
    
    
//    func setGPSEvent(components: [String]) -> SimConnectShipEvent {
//      var gpsEvent = SimConnectShipEvent()
//      gpsEvent.coordinate = CLLocationCoordinate2D(latitude: Double(components[2]) ?? 41, longitude: Double(components[1]) ?? -90)
//      gpsEvent.altitude = Double(components[3]) ?? 0.0
//      gpsEvent.heading = Double(components[4]) ?? 0.0
//      gpsEvent.speed = Double(components[5]) ?? 0.0
//      return gpsEvent
//    }

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
  let simConnect: SimConnectShips
  var simConnListener: SimConnectListener
  
  init(simConnect: SimConnectShips, simConnListener: SimConnectListener) {
    self.simConnect = simConnect
    self.simConnListener = simConnListener
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
