//
//  DrawingView.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/27/24.
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
  @Binding var canvas: PKCanvasView
  let picker = PKToolPicker.init()
  
  func makeUIView(context: Context) -> PKCanvasView {
//    canvas.drawingPolicy = .pencilOnly
//    canvas.tool = PKInkingTool(.pen, color: .white)
//    canvas.becomeFirstResponder()
//    canvas.isOpaque = false
//    
//    return canvas
    
    let canvas = PKCanvasView()
    canvas.drawingPolicy = .pencilOnly
    canvas.tool = PKInkingTool(.pen, color: .white)
    canvas.becomeFirstResponder()
    canvas.isOpaque = false
    
    return canvas
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
//    picker.addObserver(canvas)
//    picker.setVisible(true, forFirstResponder: uiView)
//    
//    DispatchQueue.main.async {
//      uiView.becomeFirstResponder()
//    }
  }
  
}
