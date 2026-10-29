//
//  AirportWeatherView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/27/26.
//

import SwiftUI

struct AirportWeatherView: View {
  let weatherItems: [WeatherItem] = [
    .init(icon: "wind", type: "Wind", value: "20", sub: "knot"),
    .init(icon: "eye", type: "Visibility", value: "10+", sub: "nautical mile"),
    .init(icon: "cloud", type: "Clouds", value: "25%", sub:"5000ft"),
    .init(icon: "thermometer.variable", type: "Temp", value: "30", sub: "c | 50 f"),
    .init(icon: "gauge.with.dots.needle.50percent", type: "Altimeter", value: "29.92", sub: "inHg | 1012mh?")
  ]
  
  @State private var selectedWeatherType: WeatherType = .METAR
  
  var body: some View {
    VStack {
      Text("`METAR KLAX 152153Z 23013G21KT 10SM FEW020 26/16 A2990 RMK AO2 SLP122 T02610156 $`")
        .padding()
        .background(.thickMaterial)
      
      ScrollView(.horizontal) {
        LazyHStack(spacing: 12) {
          ForEach(weatherItems) { item in
            WeatherDetailCard(item: item)
          }
        }
        .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
    .containerShape(.rect(cornerRadius: 32, style: .continuous))
  }
}

#Preview {
  AirportWeatherView()
}
