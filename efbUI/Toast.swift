//
//  Toast.swift
//  efbUI
//
//  Created by Bradley Pregon on 3/8/24.
//  Basically all credits go to kavsoft
//

import SwiftUI
import Neumorphic

struct RootToastView<Content: View>: View {
  @ViewBuilder var content: Content
  @State private var overlayWindow: UIWindow?
  
  var body: some View {
    content
      .onAppear {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, overlayWindow == nil {
          let window = PassthroughWindow(windowScene: windowScene)
          
          let rootController = UIHostingController(rootView: ToastGroup())
          rootController.view.frame = windowScene.keyWindow?.frame ?? .zero
          rootController.view.backgroundColor = .clear
          
          window.backgroundColor = .clear
          window.rootViewController = rootController
          window.isHidden = false
          window.isUserInteractionEnabled = true
          window.tag = 1009
          
          overlayWindow = window
        }
      }
  }
}

fileprivate class PassthroughWindow: UIWindow {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard let view = super.hitTest(point, with: event) else { return nil }
    return rootViewController?.view == view ? nil : view
  }
}

@Observable
class Toast {
  static let shared = Toast()
  fileprivate var toasts: [ToastItem] = []
  
  func present(title: String, symbol: String, tint: Color = Color.Neumorphic.main, isUserInteractionEnabled: Bool = false, timing: CGFloat = 15) {
    withAnimation(.snappy) {
      toasts.append(.init(title: title, symbol: symbol, tint: tint, isUserInteractionEnabled: isUserInteractionEnabled, timing: timing))
    }
  }
}

struct ToastItem: Identifiable {
  let id: UUID = .init()
  var title: String
  var symbol: String
  var tint: Color
  var isUserInteractionEnabled: Bool
  var timing: CGFloat
}

fileprivate struct ToastGroup: View {
  var model = Toast.shared
  
  var body: some View {
    GeometryReader {
      let size = $0.size
      let safeArea = $0.safeAreaInsets
      
      ZStack {
        ForEach(model.toasts) { toast in
          ToastView(size: .init(width: (size.width / 2), height: 75), item: toast)
            .offset(y: offsetY(toast))
            .zIndex(Double(model.toasts.firstIndex(where: { $0.id == toast.id }) ?? 0))
        }
      }
      .padding(.top, safeArea.bottom == .zero ? 25 : 75)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
  }
  
  func offsetY(_ item: ToastItem) -> CGFloat {
    let index = CGFloat(model.toasts.firstIndex(where: { $0.id == item.id}) ?? 0)
    let totalCount = CGFloat(model.toasts.count) - 1
    return (totalCount - index) >= 2 ? 20 : ((totalCount - index) * 10)
  }
}

fileprivate struct ToastView: View {
  var size: CGSize
  var item: ToastItem
  @State private var delayTask: DispatchWorkItem?
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20).softOuterShadow()
        .foregroundStyle(item.tint)
      HStack(spacing: 12) {
        Image(systemName: item.symbol)
          .font(.title)
        Text(item.title)
          .fontWeight(.semibold)
      }
    }
    .frame(width: size.width, height: size.height)
    .gesture(
      DragGesture(minimumDistance: 0)
        .onEnded {
          guard item.isUserInteractionEnabled else { return }
          let endY = $0.translation.height
          let velocityY = $0.velocity.height
          
          if (endY + velocityY) < 100 {
            removeToast()
          }
        }
    )
    .onAppear {
      guard delayTask == nil else { return }
      delayTask = .init(block: {
        removeToast()
      })
      
      if let delayTask {
        DispatchQueue.main.asyncAfter(deadline: .now() + item.timing, execute: delayTask)
      }
    }
    .transition(.offset(y: -200))
  }
  
  func removeToast() {
    if let delayTask {
      delayTask.cancel()
    }
    withAnimation(.snappy) {
      Toast.shared.toasts.removeAll { $0.id == item.id }
    }
  }

}
