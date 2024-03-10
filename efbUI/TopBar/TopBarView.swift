//
//  MapTopBar.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/3/21.
//

import SwiftUI
import CoreLocation
import SwiftData
//import AVFoundation

// Linked list
// Each node can be an airport, vor, navaid, departure, arrival, any type of navigation aid with a coordinate
// upon simbrief api fetch, compile route and load it into LinkedList

// Typical route format:
// head -> Airport
// nodes -> each route component
// tail -> Airport

struct Waypoint {
  var name: String
  var type: String
}

struct WaypointsContainer: View {
  var waypoints: [Waypoint]
  
  var body: some View {
    HStack {
      ForEach(waypoints, id:\.name) { waypoint in
        WptView(wpt: waypoint)
      }
    }
  }
  
  func WptView(wpt: Waypoint) -> some View {
    Button {
      print("Tapped")
    } label: {
      Text(wpt.name)
        .padding(8)
        .background(.blue)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }
  }
}

struct CustomInputView: View {
  @Binding var waypoints: [Waypoint]
  @State private var currentInput: String = ""
  
  var body: some View {
    TextField("Enter wpt", text: $currentInput) {
      let wpt = Waypoint(name: currentInput, type: "VOR")
      waypoints.append(wpt)
      currentInput = ""
    }
    .textFieldStyle(.roundedBorder)
    .frame(maxWidth: 300)
    .autocorrectionDisabled()
    .textInputAutocapitalization(.characters)
  }
}

class LinkedList {
  var head: Node?
  
  func append(value: Any) {
    let newNode = Node(value: value)
    
    if head == nil {
      head = newNode
    } else {
      var current = head
      while current?.next != nil {
        current = current?.next
      }
      current?.next = newNode
    }
  }
  
  func printList() {
    var current = head
    while current != nil {
      if current?.next != nil {
        print(current!.value, terminator: " -> ")
      } else {
        print(current!.value)
      }
      current = current?.next
    }
  }
}

class Node {
  var value: Any
  var next: Node?
  
  init(value: Any) {
    self.value = value
  }
}

struct TopBarView: View {
  private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State private var currentZuluTime24: String = ""
  @State private var currentTime: String = ""
  @Environment(SimConnectShipObserver.self) var simConnect
  @Environment(SimBriefViewModel.self) var simbrief
  
  let topOffset: CGFloat = 65
  let middleOffset: CGFloat = 300
  let bottomOffset: CGFloat = 600
  
  @State private var dragOffset: CGSize = .zero
  @State private var position: CGFloat = 65
  @State private var halfExpanded: Bool = false
  @State private var fullExpanded: Bool = false
  
  @Query var simbriefUser: [SimBriefUser]
  @State var route: String = ""
  
  //  let speechSynth = AVSpeechSynthesizer()
  
  var simConnectListener: SimConnectListener = SimConnectListener()
  
  //  @State private var flightPlan: OFPSchema? = nil
  
  @State private var waypoints: [Waypoint] = []
  
  var body: some View {
    VStack {
      HStack(alignment: .center, spacing: 20) {
        Button {
          // TODO: Instantiate server once. Don't keep reinstantiating
          let server = SimConnectServer(simConnect: simConnect, simConnListener: simConnectListener)
          if !server.isRunning {
            do {
              try server.start()
            } catch {
              print("Error trying to start SimConnect server: \(error)")
            }
          } else {
            server.stop()
          }
        } label: {
          Image(systemName: "target")
            .frame(width: 25, height: 25, alignment: .center)
            .font(.title)
            .foregroundStyle(getServerState())
        }
        .padding(.leading, 40)
        
        Spacer()
          .frame(width: 40)
        
        HStack {
          VStack {
            Text("Heading")
              .font(.caption)
            Text("\(roundToTenths(simConnect.ship?.heading ?? .zero))º")
          }
          VStack {
            Text("GPS Altitude")
              .font(.caption)
            Text("\(roundToTenths((simConnect.ship?.altitude ?? .zero) * 3.281))'") // meters to feet
          }
          VStack {
            Text("Speed")
              .font(.caption)
            Text("\(roundToTenths((simConnect.ship?.speed ?? .zero) * 1.944))kt") // m/s to knots
          }
        }
        .fontWeight(.semibold)
        
        // i do not know why i wanted to do this
        //        Button {
        //          let utter = AVSpeechUtterance(string: "hello world")
        //          utter.voice = AVSpeechSynthesisVoice(language: "en-US")
        //          utter.rate = 0.5
        //
        //          speechSynth.speak(utter)
        //        } label: {
        //          Text("Speech")
        //        }
        //        .buttonStyle(.bordered)
        
        Spacer()
        Text(currentZuluTime24)
        Spacer()
      }
      .padding([.top], 15)
      Spacer()
      
      if halfExpanded {
        //        VStack {
        //          WaypointsContainer(waypoints: waypoints)
        //          CustomInputView(waypoints: $waypoints)
        //        }
        //        .padding()
        
        if let ofp = simbrief.ofp {
          // TODO: build array from ofp including origin, waypoints, destination
          // TODO: Color for Airports, color for Departures, color for Arrivals, color for TOC/TOD
          WrappingHStack(models: ofp.navlog.filter { $0.type != "apt" }) { wpt in
            Button {
              print("\(wpt.ident) tapped")
            } label: {
              Text(wpt.isSidStar == "1" && wpt.ident != "TOC" && wpt.ident != "TOD" ? "\(wpt.via).\(wpt.ident)" : wpt.ident)
                .padding(8)
                .background(wpt.ident == "TOC" || wpt.ident == "TOD" ? Color.green : Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .font(.caption)
            }
          }
          .frame(maxWidth: 600, maxHeight: 400)
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
      }
      
      // Full -> OFP
      if fullExpanded {
        Text("full expanded view")
      }
      
      Spacer()
      VStack {
        RoundedRectangle(cornerRadius: 10)
          .frame(width: 200, height: 8)
          .foregroundStyle(.gray)
      }
      .offset(x: 0, y: -10)
      .gesture(
        DragGesture()
          .onChanged { self.dragOffset = $0.translation }
          .onEnded { value in
            withAnimation {
              // bar is at top (40)
              if self.position == topOffset {
                
                // minimal change -> snap to top
                if value.translation.height < 0 && value.translation.height < 50 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
                
                //                   pulled down a little -> middle
                else if value.translation.height >= 50 && value.translation.height <= 100 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pulled a lot -> bottom
                else if value.translation.height > 100 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
              }
              
              // bar is at middle (300)
              else if self.position == middleOffset {
                // minimal change -> snap to middle
                if value.translation.height > -50 && value.translation.height < 50 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pushed a little -> top
                else if value.translation.height <= -50 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
                
                // pulled a little -> bottom
                else if value.translation.height >= 50 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
              }
              
              // bar is at bottom (500)
              else {
                // minimal change -> snap to bottom
                if value.translation.height > 0 && value.translation.height > -50 {
                  self.position = bottomOffset
                  halfExpanded = true
                  fullExpanded = true
                }
                
                // pushed up slightly -> middle
                else if value.translation.height <= -50 && value.translation.height <= -100 {
                  self.position = middleOffset
                  halfExpanded = true
                  fullExpanded = false
                }
                
                // pushed up enough -> top
                else if value.translation.height < -100 {
                  self.position = topOffset
                  halfExpanded = false
                  fullExpanded = false
                }
              }
              
              self.dragOffset = .zero
            }
          }
      )
    }
    .frame(height: dragOffset.height + position)
    .onReceive(timer) { _ in
      getCurrentZuluTime24()
    }
  }
  
  func getServerState() -> Color {
    switch simConnectListener.serverState {
    case .connected:
      return .green
    case .heartbeat:
      return .blue
    case .stopped:
      return .red
    }
  }
  
  func getCurrentZuluTime24() {
    let df = DateFormatter()
    df.dateFormat = "HH:mm"
    df.timeZone = TimeZone(identifier: "UTC")
    let currentDate = Date()
    let zulu = df.string(from: currentDate)
    currentZuluTime24 = "\(zulu)z"
  }
  
  func roundToTenths(_ number: Double) -> String {
    let roundedNumber = number.rounded(toPlaces: 0)
    let nf = NumberFormatter()
    nf.minimumFractionDigits = 0
    nf.maximumFractionDigits = 0
    return nf.string(from: NSNumber(value: roundedNumber)) ?? ""
  }
  
}

//#Preview {
//  TopBarView()
//}

// Adapted from: https://stackoverflow.com/questions/62102647/swiftui-hstack-with-wrap-and-dynamic-height/62103264#62103264
struct WrappingHStack<Model, V>: View where Model: Hashable, V: View {
  typealias ViewGenerator = (Model) -> V
  
  var models: [Model]
  var viewGenerator: ViewGenerator
  var horizontalSpacing: CGFloat = 4
  var verticalSpacing: CGFloat = 4
  
  @State private var totalHeight = CGFloat.zero
  
  var body: some View {
    VStack {
      GeometryReader { geometry in
        self.generateContent(in: geometry)
      }
    }
    .frame(height: totalHeight)
  }
  
  private func generateContent(in geometry: GeometryProxy) -> some View {
    var width = CGFloat.zero
    var height = CGFloat.zero
    
    return ZStack(alignment: .topLeading) {
      ForEach(self.models, id: \.self) { models in
        viewGenerator(models)
          .padding(.horizontal, horizontalSpacing)
          .padding(.vertical, verticalSpacing)
          .alignmentGuide(.leading, computeValue: { dimension in
            if (abs(width - dimension.width) > geometry.size.width) {
              width = 0
              height -= dimension.height
            }
            let result = width
            if models == self.models.last! {
              width = 0 //last item
            } else {
              width -= dimension.width
            }
            return result
          })
          .alignmentGuide(.top, computeValue: { dimension in
            let result = height
            if models == self.models.last! {
              height = 0 // last item
            }
            return result
          })
      }
    }.background(viewHeightReader($totalHeight))
  }
  
  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
    return GeometryReader { geometry -> Color in
      let rect = geometry.frame(in: .local)
      DispatchQueue.main.async {
        binding.wrappedValue = rect.size.height
      }
      return .clear
    }
  }
}
