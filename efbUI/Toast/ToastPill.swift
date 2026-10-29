//
//  ToastPill.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/25/26.
//

import SwiftUI

struct ToastPill: View {
  let toast: Toast
  let onDismiss: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: toast.icon)
      Text(toast.title)
        .font(.callout)
        .fontWeight(.semibold)
      
      Button(action: onDismiss) {
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
