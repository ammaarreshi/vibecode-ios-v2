//
//  MicButton.swift
//  VibeCodeAlpha
//
//  Reusable Siri-style mic button with animated mesh gradient border
//

import SwiftUI

struct MicButton: View {
    let isRecording: Bool
    let isBuildingMode: Bool
    let action: () -> Void
    
    @State private var spinAngle: Double = 0
    
    var body: some View {
        Button(action: action) {
            Group {
                if isBuildingMode {
                    // Spinning circle during building
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(spinAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                spinAngle = 360
                            }
                        }
                } else {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .frame(width: 96, height: 96)
            .foregroundStyle(.white)
            .font(.system(size: 32, weight: .semibold))
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
        .buttonStyle(.plain)
        .disabled(isBuildingMode)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MicButton(isRecording: false, isBuildingMode: false) { }
    }
}
