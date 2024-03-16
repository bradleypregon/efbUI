//
//  ToastTestContentView.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//

import SwiftUI

struct ToastTestContentView: View {
  var body: some View {
    Button {
      Toast.shared.present(title: "10mi past KDSM: Last Call", symbol: "airplane.departure", isUserInteractionEnabled: true)
    } label: {
      Text("Toast")
    }
  }
}

#Preview {
  RootToastView {
    ToastTestContentView()
  }
}
