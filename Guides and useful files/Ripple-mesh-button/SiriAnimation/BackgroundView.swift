//
//  BackgroundView.swift
//  SiriAnimation
//
//  Created by Meng To on 18/6/24.
//

import SwiftUI

struct BackgroundView: View {
    @Binding var state: ContentView.SiriState
    @Binding var origin: CGPoint
    @Binding var counter: Int
    @State private var showWelcomeText2 = false
    
    private var scrimOpacity: Double {
        switch state {
        case .none:
            0
        case .thinking:
            0.8
        }
    }
    
    private var iconName: String {
        switch state {
        case .none:
            "mic"
        case .thinking:
            "pause"
        }
    }

    var body: some View {
        ZStack {
            Image("Background 9", bundle: .main)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: state == .thinking ? 10 : 0)
                .ignoresSafeArea()
                .scaleEffect(1.03) // avoids clipping
            
            Rectangle()
                .fill(Color.black)
                .opacity(scrimOpacity)
                .scaleEffect(1.2) // avoids clipping
            
            VStack {
                welcomeText
                
                welcomeText2
                 
                siriButtonView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.bouncy, value: showWelcomeText2)
            .onPressingChanged { point in
                if let point {
                    origin = point
                    counter += 1
                }
            }
            .padding(.bottom, 64)
        }
        .onChange(of: state) {
            if state == .thinking {
                showWelcomeText2 = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showWelcomeText2 = true
                }
            } else {
                showWelcomeText2 = false
            }
        }
    }
    
    @ViewBuilder
    private var welcomeText: some View {
        if state == .thinking {
            Text("Ask Siri...")
                .customAttribute(EmphasisAttribute())
                .foregroundStyle(Color.white)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .fontWeight(.bold)
                .animation(.easeInOut(duration: 0.2), value: state)
                .contentTransition(.opacity)
                .transition(TextTransition())
        }
    }
    
    @ViewBuilder
    private var welcomeText2: some View {
        if state == .thinking && showWelcomeText2 {
            Text("Okay. Ordering your favorite ramen on Uber Eats. ETA 25 mins.")
                .customAttribute(EmphasisAttribute())
                .foregroundStyle(Color.white)
                .frame(maxWidth: 240, maxHeight: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .font(.title)
                .fontWeight(.bold)
                .animation(.easeInOut(duration: 0.2), value: state)
                .contentTransition(.opacity)
                .transition(TextTransition())
        }
    }
    
    private var siriButtonView: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.9)) {
                switch state {
                case .none:
                    state = .thinking
                case .thinking:
                    state = .none
                }
            }
        } label: {
            Image(systemName: iconName)
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 96, height: 96)
                .foregroundStyle(Color.white)
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .background(
                    AnimatedMeshGradient()
                        .mask(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(lineWidth: 20)
                                .blur(radius: 10)
                        )
                        .blendMode(.lighten)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 3)
                        .fill(Color.white)
                        .blur(radius: 2)
                        .blendMode(.overlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(lineWidth: 1)
                        .fill(Color.white)
                        .blur(radius: 1)
                        .blendMode(.overlay)
                )
                .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
    }
}

#Preview {
    BackgroundView(
        state: .constant(.none),
        origin: .constant(CGPoint(x: 0.5, y: 0.5)),
        counter: .constant(0)
    )
    .previewLayout(.sizeThatFits)
}
