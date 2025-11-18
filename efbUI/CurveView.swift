//
//  CurveView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//

import SwiftUI

struct Curve: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.move(to: CGPoint(x: rect.minX, y: rect.midY))
    path.addLine(to: CGPoint(
      x: rect.minX,
      y: rect.maxY - rect.midY + (rect.midY/2))
    )
    path.addQuadCurve(
      to: CGPoint(x: rect.midX - (rect.midX/2), y: rect.maxY),
      control: CGPoint(x: rect.minX, y: rect.maxY)
    )
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    
    return path
  }
}

#Preview {
  Curve()
    .stroke(.gray.mix(with: .black, by: 0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
    .frame(width: 75, height: 75)
}
