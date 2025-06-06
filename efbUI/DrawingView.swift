//
//  DrawingView.swift
//  efbUI
//
//  Created by Bradley Pregon on 2/27/24.
//

import SwiftUI
import PencilKit

struct DrawingView: UIViewRepresentable {
  @Binding var drawing: PKDrawing
  @Binding var tool: PKTool
  var pencilOnly: Bool?
  
  func makeUIView(context: Context) -> PKCanvasView {
//    let canvas = (pencilOnly ?? false) ? PencilOnlyCanvasView() : PKCanvasView()
    let canvas = PKCanvasView()
    canvas.becomeFirstResponder()
    canvas.delegate = context.coordinator
    canvas.tool = tool
    canvas.drawingGestureRecognizer.isEnabled = false
    canvas.isUserInteractionEnabled = true
    
    canvas.drawingPolicy = .pencilOnly
    canvas.backgroundColor = .clear
    canvas.isOpaque = false
    return canvas
  }
  
  func updateUIView(_ canvas: PKCanvasView, context: Context) {
    canvas.tool = tool
    
    if canvas.drawing != drawing {
      canvas.drawing = drawing
    }
    canvas.backgroundColor = .clear
  }
  
  class Coordinator: NSObject, PKCanvasViewDelegate {
    var parent: DrawingView
    
    init(_ parent: DrawingView) {
      self.parent = parent
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
      parent.drawing = canvasView.drawing
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
}

/*
 Used for PDFKit View in ChartsView to allow finger touches on PDF but pencil on Canvas
 */
class PencilOnlyCanvasView: PKCanvasView {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touches.first?.type == .pencil {
      super.touchesBegan(touches, with: event)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touches.first?.type == .pencil {
      super.touchesMoved(touches, with: event)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touches.first?.type == .pencil {
      super.touchesEnded(touches, with: event)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    if touches.first?.type == .pencil {
      super.touchesCancelled(touches, with: event)
    }
  }
}
