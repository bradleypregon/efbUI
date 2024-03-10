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
            .frame(width: size * 0.25, height: 13)
            .offset(y: -14)
          RoundedRectangle(cornerRadius: 2)
            .rotation(.degrees(0))
            .frame(width: size * 0.25, height: 13)
            .offset(y: 14)
          
          RoundedRectangle(cornerRadius: 2)
            .rotation(.degrees(90))
            .frame(width: size * 0.25, height: 13)
            .offset(x: -14)
          RoundedRectangle(cornerRadius: 2)
            .rotation(.degrees(90))
            .frame(width: size * 0.25, height: 13)
            .offset(x: 14)
        }
        .foregroundStyle(color)
      }
      
      //      Circle()
      //        .frame(width: size - 10, height: size - 10)
      //        .foregroundStyle(color)
      //        .overlay {
      //          Circle()
      //            .frame(width: size * 0.33, height: size * 0.33)
      //            .foregroundStyle(.clear)
      //        }
      Circle()
        .trim(from: 0, to: 1.0)
        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .square))
        .frame(width: 22, height: 22)
        .foregroundColor(color)
        .rotationEffect(.degrees(-90))
    }
    .frame(width: size, height: size)
  }
}

#Preview(traits: .sizeThatFitsLayout) {
  AirportIcon(isLarge: true, color: .vfr, size: 40)
}
