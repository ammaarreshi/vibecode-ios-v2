//
//  ThemeChipRow.swift
//  VibeCodeAlpha
//

import SwiftUI

struct ThemeChipRow: View {
    let themes: [AppTheme]
    @Binding var selectedTheme: AppTheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(themes) { theme in
                    ThemeChip(
                        theme: theme,
                        isSelected: theme.id == selectedTheme.id
                    ) {
                        selectTheme(theme)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func selectTheme(_ theme: AppTheme) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedTheme = theme
        }
    }
}

struct ThemeChip: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Gradient fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ThemeChipRow(
            themes: AppTheme.themes,
            selectedTheme: .constant(AppTheme.themes[0])
        )
    }
}
