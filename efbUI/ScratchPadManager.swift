//
//  ScratchPadManager.swift
//  efbUI
//
//  Created by Bradley Pregon on 10/29/26.
//

import SwiftUI
import PencilKit.PKDrawing

@Observable
class ScratchPadManager {
  var drawing: PKDrawing = PKDrawing()
  var isOpen: Bool = false
  var position: CGSize = .zero
  var size: CGSize = CGSize(width: 300, height: 300)
}
