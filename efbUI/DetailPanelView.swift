//
//  DetailPanelView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/17/25.
//

import SwiftUI

struct DetailPanelView: View {
  @Binding var detailPanelVisible: Bool
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Text("Detail")
          .font(.headline)
        Spacer()
        
        Button {
          withAnimation(.easeInOut) {
            detailPanelVisible = false
          }
        } label: {
          Text("Hide")
        }
      }
      .padding(.bottom, 8)
      
      // Detail View here
      Text("Hello")
      
      Spacer()
    }
  }
}

#Preview {
  DetailPanelView(detailPanelVisible: .constant(true))
}
