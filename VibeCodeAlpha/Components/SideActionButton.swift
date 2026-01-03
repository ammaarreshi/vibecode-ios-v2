//
//  SideActionButton.swift
//  VibeCodeAlpha
//
//  Floating side action button with glass effect
//

import SwiftUI

struct SideActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.glass)
        .tint(.white)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SideActionButton(icon: "paintpalette.fill") { }
    }
}
