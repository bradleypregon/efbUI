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
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundStyle(.secondary)
      HStack {
        VStack(alignment: .leading) {
          Text(header)
//            .foregroundStyle(.primary)
            .font(.title)
            .fontWeight(.semibold)
            .padding([.leading, .top], 8)
          Spacer()
        }
        Spacer()
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  func WindCard() -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundStyle(.secondary)
      HStack {
        VStack(alignment: .leading) {
          Text("Wind")
//            .foregroundStyle(.primary)
            .font(.title)
            .fontWeight(.semibold)
            .padding([.leading, .top], 8)
          Spacer()
        }
        Spacer()
      }
      HStack {
        Spacer()
          .frame(width: 150)
        Text("@")
//          .foregroundStyle(.secondary)
          .font(.title)
          .fontWeight(.semibold)
        Spacer()
        Text("G")
//          .foregroundStyle(.secondary)
          .font(.title)
          .fontWeight(.semibold)
        Spacer()
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  func SkyCard() -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .foregroundStyle(.secondary)
      HStack {
        VStack(alignment: .leading) {
          Text("Sky")
//            .foregroundStyle(.secondary)
            .font(.title)
            .fontWeight(.semibold)
            .padding([.leading, .top], 8)
          Spacer()
        }
        Spacer()
      }
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
    }
    .frame(maxWidth: .infinity)
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
//      .foregroundStyle(.secondary)
      .font(.title2)
      .fontWeight(.semibold)
      Spacer()
      Text("Clear")
        .padding([.trailing], 40)
//        .foregroundStyle(.secondary)
        .font(.title2)
        .fontWeight(.semibold)
    }
    .frame(maxHeight: .infinity)
  }
}

#Preview {
  SPATISTemplateView()
}
