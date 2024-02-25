//
//  Extensions.swift
//  efbUI
//
//  Created by Bradley Pregon on 12/6/23.
//

import Foundation
import UIKit
import SwiftUI
import CoreLocation

extension Double {
  func rounded(toPlaces places: Int) -> Double {
    let divisor = pow(1.0, Double(places))
    return (self * divisor).rounded()
  }
}

extension LosslessStringConvertible {
  var string: String { .init(self) }
}

extension CLLocation {
  func fetchCityState(completion: @escaping (_ city: String?, _ state:  String?, _ error: Error?) -> ()) {
    CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.administrativeArea, $1) }
  }
}

// TODO: Remove? Possibly not needed
extension UIImage {
  func resize(newWidth: CGFloat) -> UIImage? {
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newWidth))
    
    let image = renderer.image { (context) in
      self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newWidth))
    }
    
    return image
  }
  
  func rotate(angle: Angle) -> UIImage? {
    let radians = angle.radians
    var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
    // Trim off the extremely small float value to prevent core graphics from rounding it up
    newSize.width = floor(newSize.width)
    newSize.height = floor(newSize.height)
    
    UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    
    // Move origin to middle
    context.translateBy(x: newSize.width/2, y: newSize.height/2)
    // Rotate around middle
    context.rotate(by: CGFloat(radians))
    // Draw the image at its center
    self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
}

struct GlowBorder: ViewModifier {
  var color: Color
  var lineWidth: Int
  
  func body(content: Content) -> some View {
    applyShadow(content: AnyView(content), lineWidth: lineWidth)
  }
  
  func applyShadow(content: AnyView, lineWidth: Int) -> AnyView {
    if lineWidth == 0 { return content }
    return applyShadow(content: AnyView(content.shadow(color: color, radius: 1)), lineWidth: lineWidth-1)
  }
}

extension View {
  func glowBorder(color: Color, lineWidth: Int) -> some View {
    self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
  }
}
