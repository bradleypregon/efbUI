//
//  PDFKitView.swift
//  efbUI
//
//  Created by Bradley Pregon on 1/11/24.
//

import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
  let url: URL
  
  func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
    let pdf = PDFView()
    pdf.document = PDFDocument(url: self.url)
    pdf.displayMode = .singlePageContinuous
    pdf.autoScales = true
    pdf.usePageViewController(true)
    pdf.backgroundColor = UIColor.clear
    return pdf
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    uiView.document = PDFDocument(url: self.url)
  }
}
