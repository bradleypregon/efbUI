//
//  AirportIcon.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/1/24.
//

import SwiftUI

struct AirportIcon: View {
  let isLarge: Bool
  let color: Color
  let size: CGFloat
  
  var body: some View {
    ZStack {
      if isLarge {
        ZStack {
          RoundedRectangle(cornerRadius: 2)
            .rotation(.degrees(0))
            .frame(width: size * 0.25, height: .infinity)
          RoundedRectangle(cornerRadius: 2)
            .rotation(.degrees(90))
            .frame(width: size * 0.25, height: .infinity)
        }
        .foregroundStyle(color)
      }
      
      Circle()
        .frame(width: size - 10, height: size - 10)
        .foregroundStyle(color)
        .overlay {
          Circle()
            .frame(width: size * 0.33, height: size * 0.33)
            .foregroundStyle(.black)
        }
    }
    .frame(width: size, height: size)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AirportIcon(isLarge: true, color: .vfr, size: 40)
}
