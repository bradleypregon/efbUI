//
//  ToastTestContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//

import SwiftUI

struct ToastTestContentView: View {
  @Environment(ToastManager.self) private var toastManager
  
  var body: some View {
    @Bindable var toastMan = toastManager
    
    Button {
      toastManager.push(icon: "airplane.departure", title: "20nm from KDSM: Final Call")
    } label: {
      Text("Push Toast")
    }
    .frame(width: 300, height: 300)
    .overlay(alignment: .bottom) {
      ToastsView(toasts: $toastMan.toasts)
    }
  }
}

#Preview {
  ToastTestContentView()
    .environment(ToastManager())
}
