//
//  Toast.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//

import SwiftUI

struct Toast: Identifiable {
  private(set) var id: String = UUID().uuidString
  let icon: String
  let title: String
  var offsetX: CGFloat = 0
}

extension Binding<[Toast]> {
  func delete(_ id: String) {
    withAnimation(.bouncy) {
      self.wrappedValue.removeAll(where: { $0.id == id })
    }
  }
}
