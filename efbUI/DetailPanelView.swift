//
//  DetailPanelView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/17/25.
//

import SwiftUI

struct DetailPanelView: View {
  @Binding var selectedTab: SelectedTab
  @Binding var detailPanelVisible: Bool
  
  // Switch selected tab
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
      switch selectedTab {
      case .search:
        TabSearchView()
      case .flight:
        TabFlightView()
      case .airports:
        TabAirportsView()
      case .settings:
        TabSettingsView()
      default:
        EmptyView()
      }
      
      Spacer()
    }
  }
}

#Preview {
  DetailPanelView(selectedTab: .constant(SelectedTab.search), detailPanelVisible: .constant(true))
}
