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
  
  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.displayMode = .singlePageContinuous
    pdfView.autoScales = true
    pdfView.usePageViewController(true)
    pdfView.backgroundColor = .clear
    return pdfView
  }
  
  func updateUIView(_ uiView: PDFView, context: Context) {
    // Avoid reloading
    if let doc = uiView.document, doc.documentURL == url {
      return
    }
    
    if url.isFileURL {
      uiView.document = PDFDocument(url: url)
    } else {
      Task {
        do {
          let (data, _) = try await URLSession.shared.data(from: url)
          if let document = PDFDocument(data: data) {
            await MainActor.run {
              if uiView.document?.documentURL != url {
                uiView.document = document
              }
            }
          }
        } catch {
          print("Failed to load PDF: \(error)")
        }
      }
    }
  }
}
