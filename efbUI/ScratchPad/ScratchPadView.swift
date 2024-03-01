//
//  ScratchPadView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import PencilKit

struct ScratchPadView: View {
  @State var atisCanvas = PKCanvasView()
  @State var craftCanvas = PKCanvasView()
  @State var scratchCanvas = PKCanvasView()
  
  private enum ScratchPadTabs: String, CaseIterable, Identifiable {
    case ATIS, CRAFT, Blank
    var id: Self { self }
  }
  
  @State private var selectedTab: ScratchPadTabs = .ATIS
  
  var body: some View {
    VStack {
      HStack {
        /// Picker
        Picker("ScrachPad", selection: $selectedTab) {
          ForEach(ScratchPadTabs.allCases) { tab in
            Text(tab.rawValue)
          }
        }
        .pickerStyle(.segmented)
        
        /// PencilKit control buttons
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
      }
        .frame(height: 70)
      
      ZStack {
        switch selectedTab {
        case .ATIS:
          ScratchPadATIS()
          DrawingView(canvas: $atisCanvas)
        case .CRAFT:
          ScratchPadCRAFT()
          DrawingView(canvas: $craftCanvas)
        default:
          Color.Neumorphic.main
          DrawingView(canvas: $scratchCanvas)
        }
        
      }
      
    }
    
  }
}



#Preview {
  ScratchPadView()
}
