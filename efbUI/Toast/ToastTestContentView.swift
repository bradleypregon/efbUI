//
//  ToastTestContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//

import SwiftUI

struct ToastTestContentView: View {
  @State var toasts: [Toast] = []
  var body: some View {
    Button {
      showToast(image: "airplane.departure", title: "20nm from KDSM: Final Call")
    } label: {
      Text("Toast")
    }
    .toast($toasts)
  }
  
  func showToast(image: String, title: String) {
    withAnimation(.bouncy) {
      let toast = Toast { id in
        ToastView(id, image: image, title: title)
      }
      toasts.append(toast)
    }
  }
  
  @ViewBuilder
  func ToastView(_ id: String, image: String, title: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: image)
      Text(title)
        .font(.callout)
        .fontWeight(.semibold)
      
      Button {
        $toasts.delete(id)
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
      }
    }
    .foregroundStyle(.primary)
    .padding(12)
    .background {
      Capsule()
        .fill(.background)
        .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
        .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
    }
    .padding(.horizontal, 15)
  }
}

#Preview {
  ToastTestContentView()
}
