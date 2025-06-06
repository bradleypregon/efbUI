//
//  CanvasToolbarView.swift
//  efbUI
//
//  Created by Bradley Pregon on 5/24/25.
//

import SwiftUI
import PencilKit

struct CanvasToolbarView: View {
  @Binding var selTool: PKTool
  var onClear: () -> Void
  
  @State private var prevTool: PKTool? = nil
  @State private var tool: PKTool? = nil
  
  @State private var pencilWidth: CGFloat = 10
  @State private var pencilColor: Color = .red
  
  @State private var popoverVisible: Bool = false
  
  let colors: [Color] = [.red, .orange, .green, .yellow, .blue, .black, .white]
  
  var body: some View {
    HStack(spacing: 8) {
      Button {
        tool = PKInkingTool(.pen, color: UIColor(pencilColor), width: pencilWidth)
        if prevTool is PKInkingTool {
          tool = nil
        }
        if let tool {
          selTool = tool
        }
        prevTool = tool
      } label: {
        Image(systemName: "pencil")
          .frame(width: 22, height: 22)
      }
      .buttonStyle(CanvasToolbarButtonStyle(selected: tool is PKInkingTool))
      
      Button {
        popoverVisible.toggle()
      } label: {
        Image(systemName: "slider.horizontal.3")
          .frame(width: 22, height: 22)
      }
      .buttonStyle(.bordered)
      .popover(isPresented: $popoverVisible) {
        VStack(alignment: .center, spacing: 8) {
          Slider(value: $pencilWidth, in: 1...21, step: 2)
          .tint(pencilColor) // not necessary
          .padding([.trailing, .leading, .top], 12)
          .onChange(of: pencilWidth) {
            if tool is PKEraserTool {
              tool = PKEraserTool(.bitmap, width: pencilWidth)
              if let tool {
                selTool = tool
              }
            } else if tool is PKInkingTool {
              tool = PKInkingTool(.pen, color: UIColor(pencilColor), width: pencilWidth)
              if let tool {
                selTool = tool
              }
            }
          }
          Text("Width: \(Int(pencilWidth))")
          Divider()
            .padding([.leading, .trailing], 12)
          HStack(alignment: .center, spacing: 4) {
            ForEach(colors, id: \.self) { color in
              Image(systemName: pencilColor == color ? "record.circle.fill" : "circle.fill")
                .foregroundStyle(color)
                .font(.title)
                .clipShape(Circle())
                .onTapGesture {
                  pencilColor = color
                  if tool is PKInkingTool {
                    tool = PKInkingTool(.pen, color: UIColor(pencilColor), width: pencilWidth)
                    if let tool {
                      selTool = tool
                    }
                  }
                }
            }
          }
          .padding()
        }
        .frame(width: 325, height: 150)
      }
      
      Button {
        tool = PKEraserTool(.bitmap, width: pencilWidth * 2)
        if prevTool is PKEraserTool {
          tool = nil
        }
        if let tool {
          selTool = tool
        }
        prevTool = tool
      } label: {
        Image(systemName: "eraser")
          .frame(width: 22, height: 22)
      }
      .buttonStyle(CanvasToolbarButtonStyle(selected: tool is PKEraserTool))
      
      Button {
        onClear()
      } label: {
        Text("CLR")
          .frame(width: 32, height: 22)
      }
      .buttonStyle(.bordered)
      
    }
    .padding([.leading, .trailing], 8)
//    .padding(8)
// .background(Color(.systemBackground).opacity(0.6))
//    .clipShape(RoundedRectangle(cornerRadius: 8))
//    .shadow(radius: 2)
  }
}

#Preview {
  CanvasToolbarView(selTool: .constant(PKInkingTool(.pen, width: 6)), onClear: {})
}

struct CanvasToolbarButtonStyle: PrimitiveButtonStyle {
  var selected: Bool
  
  func makeBody(configuration: Configuration) -> some View {
    if selected {
      BorderedProminentButtonStyle()
        .makeBody(configuration: configuration)
    } else {
      BorderedButtonStyle()
        .makeBody(configuration: configuration)
    }
  }
}
