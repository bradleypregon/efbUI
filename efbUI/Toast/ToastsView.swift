//
//  ToastsView.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/25/26.
//

import SwiftUI

struct ToastsView: View {
  @Binding var toasts: [Toast]
  @State private var isExpanded: Bool = false
  
  var body: some View {
    ZStack(alignment: .bottom) {
      if isExpanded {
        Rectangle()
          .fill(.ultraThinMaterial)
          .ignoresSafeArea()
          .onTapGesture { isExpanded = false }
      }
      
      let layout = isExpanded ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(ZStackLayout())
      
      layout {
        ForEach($toasts) { $toast in
          let index = (toasts.count - 1) - (toasts.firstIndex(where: { $0.id == toast.id }) ?? 0)
          
          ToastPill(toast: toast) { $toasts.delete(toast.id) }
            .offset(x: toast.offsetX)
            .gesture(
              DragGesture()
                .onChanged { value in
                  let xOffset = value.translation.width < 0 ? value.translation.width : 0
                  toast.offsetX = xOffset
                }
                .onEnded { value in
                  let xOffset = value.translation.width + (value.velocity.width / 2)
                  if -xOffset > 300 {
                    $toasts.delete(toast.id)
                  } else {
                    withAnimation {
                      toast.offsetX = 0
                    }
                  }
                }
            )
            .visualEffect { [isExpanded] content, proxy in
              content
                .scaleEffect(isExpanded ? 1 : scale(index), anchor: .bottom)
                .offset(y: isExpanded ? 0 : offsetY(index))
            }
            .frame(maxWidth: .infinity)
            .transition(.asymmetric(insertion: .offset(y: 100), removal: .push(from: .top)))
        }
      }
      .onTapGesture {
        isExpanded.toggle()
      }
      .padding(.bottom, 50)
    }
    .animation(.bouncy, value: isExpanded)
    .onChange(of: toasts.isEmpty) { _, newVal in
      if newVal {
        isExpanded = false
      }
    }
  }
  
  nonisolated func offsetY(_ index: Int) -> CGFloat {
    let offset = min(CGFloat(index) * 15, 30)
    return -offset
  }
  nonisolated func scale(_ index: Int) -> CGFloat {
    let scale = min(CGFloat(index) * 0.1, 1)
    return 1 - scale
  }
}
