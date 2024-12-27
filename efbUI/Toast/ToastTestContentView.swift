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
      showToast()
    } label: {
      Text("Toast")
    }
    .toast($toasts)
  }
  
  func showToast() {
    withAnimation(.bouncy) {
      let toast = Toast { id in
        
      }
    }
  }
  
  @ViewBuilder
  func ToastView(_ id: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: "")
      Text("Xmi from KDSM: Final Call")
        .font(.callout)
      
      Button {
        print("")
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title2)
      }
    }
  }
}

#Preview {
  ToastTestContentView()
}
