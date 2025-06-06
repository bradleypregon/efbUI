//
//  ScratchPadView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import PencilKit
import Observation

enum SPCanvasPad: String, CaseIterable, Identifiable {
  case atis = "ATIS"
  case craft = "CRAFT"
  case scratch = "Scratch"
  
  var id: String { rawValue }
}

struct ScratchPadView: View {
  @State private var selectedPad: SPCanvasPad = .atis
  @State private var drawings: [SPCanvasPad: PKDrawing] = SPCanvasPad.allCases.reduce(into: [:]) { $0[$1] = PKDrawing() }
  
  @State private var tool: PKTool = PKInkingTool(.pen, color: .red, width: 10)

  var body: some View {
    VStack {
      HStack {
        /// Picker
        Picker("Pad", selection: $selectedPad) {
          ForEach(SPCanvasPad.allCases) { pad in
            Text(pad.rawValue).tag(pad)
          }
        }
        .pickerStyle(.segmented)
        
        /// PencilKit control buttons
        CanvasToolbarView(
          selTool: $tool,
          onClear: {
            drawings[selectedPad] = PKDrawing()
          }
        )
        
        // OLD Toolbar
        /*
        HStack(spacing: 20) {
          Button {
            switch selectedTab {
            case .ATIS:
              atisCanvas.tool = PKInkingTool(.pen)
            case .CRAFT:
              craftCanvas.tool = PKInkingTool(.pen)
            case .Blank:
              scratchCanvas.tool = PKInkingTool(.pen)
            }
          } label: {
            Image(systemName: "pencil")
              .font(.title)
          }
          .buttonStyle(.bordered)
          .frame(maxHeight: .infinity)
          
          Button {
            switch selectedTab {
            case .ATIS:
              atisCanvas.tool = PKEraserTool(.bitmap)
            case .CRAFT:
              craftCanvas.tool = PKEraserTool(.bitmap)
            case .Blank:
              scratchCanvas.tool = PKEraserTool(.bitmap)
            }
          } label: {
            Image(systemName: "eraser")
              .font(.title)
          }
          .buttonStyle(.bordered)
          .frame(maxHeight: .infinity)
          
          
          Button {
            switch selectedTab {
            case .ATIS:
              atisCanvas.drawing.strokes.removeAll()
            case .CRAFT:
              craftCanvas.drawing.strokes.removeAll()
            case .Blank:
              scratchCanvas.drawing.strokes.removeAll()
            }
          } label: {
            Text("Clear")
              .font(.title)
          }
          .buttonStyle(.bordered)
          .frame(maxHeight: .infinity)
          
        }
        .padding([.leading, .trailing], 40)
        */
      }
        .frame(idealHeight: 70)
      
      ZStack {
        switch selectedPad {
        case .atis:
          SPATISTemplateView()
        case .craft:
          SPCRAFTTemplateView()
        case .scratch:
          EmptyView()
        }
        
        DrawingView(drawing: Binding(
          get: { drawings[selectedPad] ?? PKDrawing() },
          set: { drawings[selectedPad] = $0 }
        ), tool: $tool)
        
      }
      
      // OLD ZStack
      /*
      ZStack {
        switch selectedTab {
        case .ATIS:
          ScratchPadATIS()
          DrawingView(canvas: $atisCanvas)
        case .CRAFT:
          ScratchPadCRAFT()
          DrawingView(canvas: $craftCanvas)
        default:
          DrawingView(canvas: $scratchCanvas)
        }
      }
      */
      
    }
  }
}



#Preview {
  ScratchPadView()
}
