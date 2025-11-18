//
//  TabBarView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/6/25.
//

import SwiftUI

struct TabBarView: View {
  @Binding var detailPanelVisible: Bool
  @Binding var notePadVisible: Bool
  
  var body: some View {
    VStack(spacing: 20) {
      Button {
        withAnimation(.easeInOut) {
          detailPanelVisible.toggle()
        }
      } label: {
        TabButtonLabel(icon: "magnifyingglass", title: "Search")
      }
      
      Button {
        withAnimation(.easeInOut) {
          detailPanelVisible.toggle()
        }
      } label: {
        TabButtonLabel(icon: "airplane.ticket", title: "Flight")
      }
      
      Button {
        withAnimation(.easeInOut) {
          detailPanelVisible.toggle()
        }
      } label: {
        TabButtonLabel(icon: "scope", title: "Airports")
      }
      
      Button {
        notePadVisible.toggle()
      } label: {
        TabButtonLabel(icon: "long.text.page.and.pencil", title: "NotePad")
      }
      
      Spacer()
      
      Button {
        withAnimation(.easeInOut) {
          detailPanelVisible.toggle()
        }
      } label: {
        TabButtonLabel(icon: "gear", title: "Settings")
      }
    }
    .padding([.leading, .trailing], 8)
    .background(.lapis.mix(with: .black, by: 0.25))
    .buttonStyle(.glass)
    .frame(height: .infinity)
  }
}

struct TabButtonLabel: View {
  let icon: String
  let title: String
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title3)
      Text(title)
        .font(.headline)
    }
    .frame(width: 80, height: 60)
  }
}

#Preview {
  TabBarView(
    detailPanelVisible: .constant(true),
    notePadVisible: .constant(false)
  )
}
