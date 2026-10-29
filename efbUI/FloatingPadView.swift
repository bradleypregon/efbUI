//
//  FloatingPadView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/29/26.
//

import SwiftUI
import PencilKit

struct FloatingPadView: View {
  @Environment(ScratchPadManager.self) var scratchPadManager
  @State var tool: PKTool = PKInkingTool(ink: .init(.pen, color: .red), width: 5)
  
  @GestureState private var dragOffset: CGSize = .zero
  
  var body: some View {
    @Bindable var pad = scratchPadManager
    
    VStack(spacing: 4) {
      RoundedRectangle(cornerRadius: 32, style: .circular)
        .frame(width: 50, height: 7)
        .padding(4)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .glassEffect(.identity)
        .gesture(
          DragGesture(coordinateSpace: .global)
            .updating($dragOffset) { value, state, _ in
              state = value.translation
            }
            .onEnded { value in
              pad.position.width += value.translation.width
              pad.position.height += value.translation.height
            }
        )
      
      DrawingView(drawing: $pad.drawing, tool: $tool)
        .frame(width: 300, height: 500)
        .glassEffect(.clear, in: .rect(cornerRadius: 32, style: .continuous))
        .overlay(alignment: .topLeading) {
          CanvasToolbarView(
            selTool: $tool,
            onClear: {
              pad.drawing = PKDrawing()
            }
          )
        }
    }
    .offset(
      x: pad.position.width + dragOffset.width,
      y: pad.position.height + dragOffset.height
    )
  }
}

#Preview {
  FloatingPadView()
    .environment(ScratchPadManager())
}
