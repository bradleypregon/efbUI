//
//  ToastManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/22/26.
//

import SwiftUI

@Observable
final class ToastManager {
  var toasts: [Toast] = []
  
  func push(icon: String, title: String) {
    withAnimation(.bouncy) { toasts.append(Toast(icon: icon, title: title)) }
  }
  
  func dismiss(_ id: String) {
    withAnimation(.bouncy) { toasts.removeAll { $0.id == id } }
  }
}
