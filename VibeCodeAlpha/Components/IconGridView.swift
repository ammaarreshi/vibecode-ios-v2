//
//  IconGridView.swift
//  VibeCodeAlpha
//

import SwiftUI

struct IconGridView: View {
    let icons: [AppIcon]
    @Binding var selectedIcon: AppIcon?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(icons) { icon in
                IconGridItem(
                    icon: icon,
                    isSelected: selectedIcon?.id == icon.id
                ) {
                    selectIcon(icon)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func selectIcon(_ icon: AppIcon) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedIcon = icon
        }
    }
}

struct IconGridItem: View {
    let icon: AppIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Icon background
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [icon.backgroundColor, icon.backgroundColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                
                // Icon symbol
                Image(systemName: icon.symbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                
                // Selection glow
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 72, height: 72)
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.5), lineWidth: 6)
                        .blur(radius: 4)
                        .frame(width: 72, height: 72)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        IconGridView(
            icons: AppIcon.generateVariations(for: AppTheme.themes[0]),
            selectedIcon: .constant(nil)
        )
    }
}
