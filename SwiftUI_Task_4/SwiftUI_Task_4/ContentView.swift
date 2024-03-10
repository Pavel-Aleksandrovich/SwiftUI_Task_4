//
//  ContentView.swift
//  SwiftUI_Task_4
//
//  Created by pavel mishanin on 10/3/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var animation: Double = 0
    
    var body: some View {
        ZStack {
            Button(action: {
                performTapAnimation()
            }, label: {
                ArrowIndicator(animation: animation)
            })
            .buttonStyle(SimpleButtonStyle())
        }
    }
    
    func performTapAnimation() {
        guard animation == 0 else { return }
        
        withAnimation(.interpolatingSpring(stiffness: 210, damping: 20)) {
            self.animation = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Ui.animateTapDuration) {
            self.animation = 0
        }
    }
}

struct ArrowIndicator: View {
    var animation: CGFloat
    
    private var playImage: some View {
        Image(systemName: "play.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            playImage
                .frame(width: animation == 0 ? 1 : Ui.iconWidth)
                .scaleEffect(animation)
                .opacity(animation)
            
            playImage
                .frame(width: Ui.iconWidth)
            
            playImage
                .frame(width: animation == 0 ? Ui.iconWidth : 1)
                .scaleEffect(1.0 - animation)
                .opacity(1.0 - animation)
            
        }
    }
}

struct SimpleButtonStyle: ButtonStyle {
    @ObservedObject var viewModel = ViewModel()
    
    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .fill(Color(white: 0.9))
            .frame(width: 100, height: 100)
            .opacity(viewModel.throttledValue ? 1 : 0)
            .overlay {
                configuration.label
                    .offset(x:2)
                    .scaleEffect(CGSize(width: viewModel.throttledValue ? Ui.scale : 1,
                                        height: viewModel.throttledValue ? Ui.scale : 1))
            }
            .onChange(of: configuration.isPressed, perform: { newValue in
                self.viewModel.value = newValue
            })
    }
}

final class ViewModel: ObservableObject {
    @Published var value: Bool = false
    @Published var throttledValue: Bool = false
    
    
    private var throttleCancellable: AnyCancellable? = nil
    
    init() {
        throttleCancellable = $value
            .removeDuplicates()
            .throttle(for: .seconds(Ui.animateTapDuration), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] val in
                withAnimation(.easeIn(duration: Ui.animateTapDuration)) {
                    self?.throttledValue = val
                }
            }
    }
}

private enum Ui {
    static let iconWidth: CGFloat = 40
    static let animateTapDuration: CGFloat = 0.22
    static let scale: CGFloat = 0.86
}
