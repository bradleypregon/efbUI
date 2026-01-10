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
  @Binding var selectedTab: SelectedTab
  
  // TODO: Style selected tab
  // TODO: Don't always toggle detail when tab is selected
  // If the same tab is tapped, close detail
  // If another tab is tapped, open that tab
  var body: some View {
    VStack(spacing: 20) {
      Button {
        withAnimation(.easeInOut) {
          if selectedTab == .search {
            detailPanelVisible.toggle()
          } else {
            selectedTab = .search
            detailPanelVisible = true
          }
        }
      } label: {
        TabButtonLabel(icon: "magnifyingglass", title: "Search")
      }
      
      Button {
        withAnimation(.easeInOut) {
          if selectedTab == .flight {
            detailPanelVisible.toggle()
          } else {
            selectedTab = .flight
            detailPanelVisible = true
          }
        }
      } label: {
        TabButtonLabel(icon: "airplane.ticket", title: "Flight")
      }
      
      Button {
        withAnimation(.easeInOut) {
          if selectedTab == .airports {
            detailPanelVisible.toggle()
          } else {
            selectedTab = .airports
            detailPanelVisible = true
          }
        }
      } label: {
        TabButtonLabel(icon: "scope", title: "Airports")
      }
      
      Button {
        withAnimation {
          notePadVisible.toggle()
        }
      } label: {
        TabButtonLabel(icon: "long.text.page.and.pencil", title: "NotePad")
      }
      
      Spacer()
      
      Button {
        withAnimation(.easeInOut) {
          if selectedTab == .settings {
            detailPanelVisible.toggle()
          } else {
            selectedTab = .settings
            detailPanelVisible = true
          }
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
  @Previewable @State var tab: SelectedTab = .search
  @Previewable @State var vis: Bool = false
  
  HStack {
    TabBarView(
      detailPanelVisible: $vis,
      notePadVisible: .constant(false),
      selectedTab: $tab
    )
    DetailPanelView(
      selectedTab: $tab,
      detailPanelVisible: $vis
    )
      .frame(width: 250)
  }
  
}
