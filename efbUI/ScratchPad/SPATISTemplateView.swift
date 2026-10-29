//
//  ScratchPadATIS.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/1/24.
//

import SwiftUI

struct SPATISTemplateView: View {
  
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Card(header: "Airport")
        Card(header: "Information")
        Card(header: "Time")
      }
      HStack {
        WindCard()
        Card(header: "Visibility")
      }
      .frame(height: 125)
      SkyCard()
      HStack {
        Card(header: "Temp")
        Card(header: "Dewpoint")
        Card(header: "Altimeter")
      }
      HStack {
        Card(header: "Runway")
        Card(header: "Remarks")
      }
    }
    .padding(8)
  }
  
  func Card(header: String) -> some View {
    RoundedRectangle(cornerRadius: 32, style: .continuous)
      .fill(Color(.secondarySystemBackground))
      .frame(width: .infinity)
      .overlay(alignment: .topLeading) {
        Text(header)
          .font(.title2)
          .fontWeight(.semibold)
          .padding(18)
      }
  }
  
  func WindCard() -> some View {
    RoundedRectangle(cornerRadius: 32, style: .continuous)
      .fill(Color(.secondarySystemBackground))
      .frame(width: .infinity)
      .overlay(alignment: .topLeading) {
        Text("Wind")
          .font(.title2)
          .fontWeight(.semibold)
          .padding(18)
      }
      .overlay(alignment: .center) {
        HStack(alignment: .center, spacing: 120) {
          Text("@")
          Text("G")
        }
        .padding(.top, 25)
        .font(.title)
        .fontWeight(.semibold)
      }

  }
  
  func SkyCard() -> some View {
    RoundedRectangle(cornerRadius: 32, style: .continuous)
      .fill(Color(.secondarySystemBackground))
      .frame(width: .infinity)
      .overlay(alignment: .topLeading) {
        Text("Sky Conditions")
          .font(.title2)
          .fontWeight(.semibold)
          .padding(18)
      }
      .overlay(alignment: .center) {
        VStack {
          SkyCondition()
            .padding()
          Divider()
            .padding([.trailing, .leading], 60)
          SkyCondition()
            .padding()
          Divider()
            .padding([.trailing, .leading], 60)
          SkyCondition()
            .padding()
        }
        .padding([.top, .bottom], 20)
      }
  }
  
  func SkyCondition() -> some View {
    HStack {
      Spacer()
        .frame(maxWidth: 200)
      HStack(spacing: 50) {
        Text("OVC")
        Text("BKN")
        Text("FEW")
        Text("@")
      }
      .font(.title2)
      .fontWeight(.semibold)
      Spacer()
      Text("Clear")
        .padding([.trailing], 40)
        .font(.title2)
        .fontWeight(.semibold)
    }
    .frame(maxHeight: .infinity)
  }
}

#Preview {
  SPATISTemplateView()
}
