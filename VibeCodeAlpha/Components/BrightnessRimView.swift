//
//  BrightnessRimView.swift
//  VibeCodeAlpha
//
//  Glowing white rim overlay used during recording/building states
//  This is the subtle white glow that appears around the screen edges
//

import SwiftUI

struct BrightnessRimView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 10))
                .blur(radius: 5)
                .blendMode(.overlay)
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 10))
                .blur(radius: 10)
                .blendMode(.softLight)
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 5))
                .blur(radius: 2)
                .blendMode(.overlay)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BrightnessRimView()
    }
}
