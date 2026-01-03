//
//  AppIconView.swift
//  VibeCodeAlpha
//
//  App icon view for saved apps with long-press to delete support
//

import SwiftUI

struct AppIconView: View {
    let app: SavedApp
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [app.iconColor, app.iconColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .overlay {
                        Image(systemName: app.iconSymbol)
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: app.iconColor.opacity(0.4), radius: 12, y: 6)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress()
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
            )
            
            Text(app.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AppIconView(
            app: SavedApp(name: "Test", iconSymbol: "star.fill", iconColor: .blue, htmlContent: ""),
            onTap: {},
            onLongPress: {}
        )
    }
}
