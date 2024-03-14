//
//  NewRangedSliderView.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/13/24.
//

import Foundation
import SwiftUI

struct RangedSliderView: View {
  let currentValue: Binding<ClosedRange<Float>>
  let sliderBounds: ClosedRange<Float>
  let step: Float
  
  init(value: Binding<ClosedRange<Float>>, bounds: ClosedRange<Float>, step: Float) {
    self.currentValue = value
    self.sliderBounds = bounds
    self.step = step
  }
  
  var body: some View {
    GeometryReader { geometry in
      sliderView(sliderSize: geometry.size)
    }
  }
  
  @ViewBuilder
  private func sliderView(sliderSize: CGSize) -> some View {
    let sliderViewYCenter = sliderSize.height / 2
    ZStack {
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.gray)
        .frame(height: 4)
      ZStack {
        let sliderBoundDifference = sliderBounds.upperBound - sliderBounds.lowerBound
        let stepWidthInPixel = CGFloat(sliderSize.width) / CGFloat(sliderBoundDifference)
        
        // Calculate Left Thumb initial position
        let leftThumbLocation: CGFloat = CGFloat(currentValue.wrappedValue.lowerBound - sliderBounds.lowerBound) * stepWidthInPixel
        
        // Calculate right thumb initial position
        let rightThumbLocation = CGFloat(currentValue.wrappedValue.upperBound - sliderBounds.lowerBound) * stepWidthInPixel
        
        // Path between both handles
        lineBetweenThumbs(from: .init(x: leftThumbLocation, y: sliderViewYCenter), to: .init(x: rightThumbLocation, y: sliderViewYCenter))
        
        // Left Thumb Handle
        thumbView(position: CGPoint(x: leftThumbLocation, y: sliderViewYCenter), value: Float(currentValue.wrappedValue.lowerBound))
          .highPriorityGesture(
            DragGesture()
              .onChanged { dragValue in
                let dragLocation = (dragValue.location)
                let xThumbOffset = min(max(0, dragLocation.x), sliderSize.width)
                
                let newValue = Float(sliderBounds.lowerBound) + Float(xThumbOffset / stepWidthInPixel)
                
                // Stop the range thumbs from colliding each other
                if newValue < currentValue.wrappedValue.upperBound {
                  currentValue.wrappedValue = newValue...currentValue.wrappedValue.upperBound
                }
          })
        
        // Right Thumb Handle
        thumbView(position: CGPoint(x: rightThumbLocation, y: sliderViewYCenter), value: currentValue.wrappedValue.upperBound)
          .highPriorityGesture(
            DragGesture()
              .onChanged { dragValue in
                let dragLocation = dragValue.location
                let xThumbOffset = min(max(CGFloat(leftThumbLocation), dragLocation.x), sliderSize.width)
                
                var newValue = Float(xThumbOffset / stepWidthInPixel)
                newValue = min(newValue, Float(sliderBounds.upperBound))
                
                // Stop the range thumbs from colliding each other
                if newValue > currentValue.wrappedValue.lowerBound {
                  currentValue.wrappedValue = currentValue.wrappedValue.lowerBound...newValue
                }
          })
      }
    }
  }
  
  func lineBetweenThumbs(from: CGPoint, to: CGPoint) -> some View {
    Path { path in
      path.move(to: from)
      path.addLine(to: to)
    }.stroke(Color.blue, lineWidth: 4)
  }
  
  func thumbView(position: CGPoint, value: Float) -> some View {
    ZStack {
      Text(String(value))
        .font(.system(size: 10, weight: .semibold))
        .offset(y: 20)
      Circle()
        .frame(width: 24, height: 24)
        .foregroundColor(.blue)
        .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle())
    }
    .position(x: position.x, y: position.y)
  }
}
