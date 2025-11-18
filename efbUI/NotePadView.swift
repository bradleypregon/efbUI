//
//  NotePadView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//

import SwiftUI

struct NotePadView: View {
  @Binding var isVisible: Bool
  @State private var dragOffset: CGSize = .zero
  @State private var accumulatedOffset: CGSize = .zero
  
  @State private var width: CGFloat = 300
  @State private var height: CGFloat = 400
  
  let cornerRadius: CGFloat = 24
  
  var body: some View {
    if isVisible {
      ZStack {
        // Resize drag handle(s) positioning
        // Hacky VStack/HStack
        VStack {
          Spacer()
          HStack {
            Curve()
              .stroke(.secondary, style: StrokeStyle(lineWidth: 2.25, lineCap: .round, lineJoin: .round))
              .frame(width: 125, height: 125, alignment: .bottomLeading)
              .offset(x: -10, y: 10)
              .gesture(
                // Translate Drag Gesture
                DragGesture()
                  .onChanged { val in
                    width = max(200, width + -(val.translation.width))
                    height = max(200, height + val.translation.height)
                  }
              )
            Spacer()
          }
        }
        
        // Main content
        VStack(spacing: 8) {
          Capsule(style: .continuous)
            .frame(width: 50, height: 5)
            .foregroundStyle(.gray)
            .padding(.top, 4)
            .gesture(
              // Resize Drag Gesture
              DragGesture()
                .onChanged { value in
                  dragOffset = value.translation
                }
                .onEnded { value in
                  accumulatedOffset.width += value.translation.width
                  accumulatedOffset.height += value.translation.height
                  dragOffset = .zero
                }
            )
          
          HStack(spacing: 8) {
            Text("Drawing tools")
            
            Spacer()
            
            Button {
              isVisible = false
            } label: {
              Image(systemName: "checkmark.circle.fill")
                .font(.title)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.cream)
          }
          .padding([.leading, .trailing], 8)
          
          RoundedRectangle(cornerRadius: cornerRadius)
            .padding(4)
            .overlay {
              Text("Drawing view here")
            }
        }
      }
      .padding(4)
      .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
      .shadow(radius: 8)
      .offset(x: accumulatedOffset.width + dragOffset.width,
              y: accumulatedOffset.height + dragOffset.height)
      .transition(.scale.combined(with: .opacity))
      .animation(.easeInOut, value: isVisible)
      .frame(width: width, height: height)
    }
  }
}

#Preview {
  NotePadView(isVisible: .constant(true))
}
