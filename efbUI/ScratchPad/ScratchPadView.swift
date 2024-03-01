//
//  ScratchPadView.swift
//  efbUI
//
//  Created by Bradley Pregon on 11/2/21.
//

import SwiftUI
import PencilKit

struct ScratchPadView: View {
  
  @State private var selectedScreenIndex = 0
  
  @State var atisCanvas = PKCanvasView()
  @State var craftCanvas = PKCanvasView()
  @State var scratchCanvas = PKCanvasView()
  
  var tabs = ["ATIS", "CRAFT", "Blank"]
  
  var body: some View {
    VStack {
      Spacer()
      Divider()
      
      // Horizontal Icons
      HStack {
        ForEach(0..<3, id: \.self) { number in
          Spacer()
          Button (action: {
            self.selectedScreenIndex = number
          }, label: {
            Text(tabs[number])
              .font(.system(size: 20, weight: .light, design: .rounded))
              .foregroundColor(self.selectedScreenIndex == number ? .black : Color(UIColor.lightGray))
          })
          Spacer()
        }
        Spacer()
        Button (action: {
          //
        }, label: {
          Image(systemName: "list.bullet.circle")
            .font(.title)
        })
        Spacer()
      }
      //Divider()
      // Controlling each button
      ZStack {
        switch selectedScreenIndex {
        case 0:
          Image("ATIS")
            .resizable()
          DrawingView(canvas: $atisCanvas)
        case 1:
          Image("CRAFT")
            .resizable()
          DrawingView(canvas: $craftCanvas)
        default:
          DrawingView(canvas: $scratchCanvas)
        }
        
      }
      
    }
    
  }
}



#Preview {
  ScratchPadView()
}
