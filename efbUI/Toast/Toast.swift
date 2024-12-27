//
//  Toast.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//  Basically all credits go to kavsoft
//

import SwiftUI

struct Toast: Identifiable {
  private(set) var id: String = UUID().uuidString
  var content: AnyView
  
  init(@ViewBuilder content: @escaping (String) -> some View) {
    self.content = .init(content(id))
  }
}

extension View {
  @ViewBuilder
  func toast(_ toasts: Binding<[Toast]>) -> some View {
    self
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
