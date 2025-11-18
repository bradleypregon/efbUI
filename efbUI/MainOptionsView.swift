//
//  MapOptionsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//
import SwiftUI

struct MainOptionsView: View {
  @State private var expanded: Bool = true
  @Binding var routeVisible: Bool
  @Binding var weatherVisible: Bool
  @Binding var telemetryVisible: Bool
  @Binding var pinboardVisible: Bool
  
  var body: some View {
    VStack(alignment: .leading) {
      // Top Row
      HStack(spacing: 12) {
        Toggle("Expand", systemImage: "square.grid.2x2", isOn: $expanded.animation())
          .tint(.primary)
          .labelStyle(.iconOnly)
        
        if expanded {
          // TODO: If Portrait Mode and Detail Panel visible, Toggle .iconOnly
          // Should I pass in a variable or handle it here?
          
          // Disabled if no route
          Toggle("Route", systemImage: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", isOn: $routeVisible)
            .tint(.primary)
            .disabled(true)
          
          Toggle("Weather", systemImage: "cloud.sun", isOn: $weatherVisible)
            .tint(weatherVisible ? .vfr : .primary)
          
          Toggle("Telemetry", systemImage: "gauge.with.needle", isOn: $telemetryVisible)
            .tint(telemetryVisible ? .vfr : .primary)
            .symbolEffect(.rotate.clockwise.byLayer, options: .nonRepeating, value: telemetryVisible)
          
          // Disabled if no route
          Toggle("Pin Board", systemImage: "pin", isOn: .constant(true))
            .tint(.primary)
            .disabled(true)
        }
      }
      .font(.headline)
      .fontWeight(.semibold)
      .toggleStyle(.button)
      .labelStyle(.titleAndIcon)
      .contentTransition(.symbolEffect(.replace))
      .padding(12)
      .background(.ultraThinMaterial)
      .clipShape(Capsule())
      
      // Vertical Toggles
      VStack(spacing: 12) {
        //        Toggle("Satellite", systemImage: mapViewModel.satelliteVisible ? "globe.americas.fill" : "globe.americas", isOn: $mapViewModel.satelliteVisible)
        Toggle("Satellite", systemImage: "globe.americas", isOn: .constant(true))
          .font(.title2)
          .tint(.primary)
          .toggleStyle(.button)
          .labelStyle(.iconOnly)
          .contentTransition(.symbolEffect)
        
        //        Toggle("Communications", systemImage: mapViewModel.enrouteCommsVisible ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash", isOn: $mapViewModel.enrouteCommsVisible)
        Toggle("Communications", systemImage: "antenna.radiowaves.left.and.right.slash", isOn: .constant(true))
          .font(.title2)
          .tint(.closed)
          .toggleStyle(.button)
          .labelStyle(.iconOnly)
          .contentTransition(.symbolEffect)
        
        //        Toggle("Drawing", systemImage: drawingEnabled ? "pencil" : "pencil.slash", isOn: $drawingEnabled)
        Toggle("Drawing", systemImage: "pencil.slash", isOn: .constant(true))
          .font(.title2)
          .tint(.grass)
          .toggleStyle(.button)
          .labelStyle(.iconOnly)
          .contentTransition(.symbolEffect)
        
        Divider()
          .frame(width: 24)
        
        Group {
          Toggle("Lg", systemImage: "l.square", isOn: .constant(true))
            .tint(.vfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
          
          Toggle("Md", systemImage: "m.square", isOn: .constant(true))
            .tint(.vfr)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
          
          Toggle("Sm", systemImage: "s.square", isOn: .constant(true))
            .tint(.primary)
            .toggleStyle(.button)
            .labelStyle(.iconOnly)
        }
        .font(.title2)
        
        
        //        Spacer()
        //          .frame(height: 15)
        
        //        Toggle("Lg", isOn: $mapViewModel.displayLg)
        //          .font(.title2)
        //          .tint(.mvfr)
        //          .toggleStyle(.button)
        //          .onChange(of: mapViewModel.displayLg) {
        //            do {
        //              guard let map = proxyMap?.map else { return }
        //              var layer = try map.layer(withId: Id.lgAirports)
        //              layer.visibility = mapViewModel.displayLg ? .constant(.visible) : .constant(.none)
        //            } catch {
        //              print("Error changing visiblity of large airports")
        //            }
        //          }
        //        Toggle("Md", isOn: $mapViewModel.displayMd)
        //          .font(.title2)
        //          .tint(.mvfr)
        //          .toggleStyle(.button)
        //          .onChange(of: mapViewModel.displayMd) {
        //            do {
        //              guard let map = proxyMap?.map else { return }
        //              var layer = try map.layer(withId: Id.mdAirports)
        //              layer.visibility = mapViewModel.displayMd ? .constant(.visible) : .constant(.none)
        //            } catch {
        //              print("Error changing visiblity of medium airports")
        //            }
        //          }
        //        Toggle("Sm", isOn: $mapViewModel.displaySm)
        //          .font(.title2)
        //          .tint(.mvfr)
        //          .toggleStyle(.button)
        //          .onChange(of: mapViewModel.displaySm) {
        //            do {
        //              guard var layer = try proxyMap?.map?.layer(withId: Id.smAirports) else {
        //                print("Error getting airport layer")
        //                return
        //              }
        //              layer.visibility = mapViewModel.displaySm ? .constant(.visible) : .constant(.none)
        //            } catch {
        //              print("Error changing visiblity of small airports")
        //            }
        //          }
      }
      .padding(12)
      .background(.ultraThinMaterial)
      .clipShape(Capsule())
    }
  }
}

#Preview {
  MainOptionsView(
    routeVisible: .constant(false),
    weatherVisible: .constant(true),
    telemetryVisible: .constant(false),
    pinboardVisible: .constant(true)
  )
}
