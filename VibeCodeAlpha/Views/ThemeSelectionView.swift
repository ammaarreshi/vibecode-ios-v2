//
//  ThemeSelectionView.swift
//  VibeCodeAlpha
//
//  Theme selection screen with Liquid Glass styling
//

import SwiftUI

struct ThemeSelectionView: View {
    @Bindable var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    header
                        .padding(.top, 16)
                    
                    Spacer()
                    
                    // Preview of current variation
                    if let variation = appState.currentVariation {
                        WebPreviewView(htmlContent: variation.previewContent)
                            .frame(width: geometry.size.width - 48, height: geometry.size.height * 0.55)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .shadow(color: appState.selectedTheme.primaryColor.opacity(0.4), radius: 30, y: 10)
                    }
                    
                    Spacer()
                    
                    // Theme selection row
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose a theme")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                        
                        ThemeChipRow(
                            themes: AppTheme.themes,
                            selectedTheme: Binding(
                                get: { appState.selectedTheme },
                                set: { newTheme in
                                    appState.selectedTheme = newTheme
                                    appState.applyThemeToAllVariations()
                                }
                            )
                        )
                    }
                    .padding(.bottom, 24)
                    
                    // Bottom action row
                    bottomActionRow
                        .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        Text("Theme")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActionRow: some View {
        HStack {
            // Back button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.flowState = .variations
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.medium))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.glass)
            .tint(.white)
            
            Spacer()
            
            // Continue button
            Button {
                appState.proceedToIcons()
            } label: {
                HStack(spacing: 8) {
                    Text("Continue")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .frame(height: 52)
                .padding(.horizontal, 24)
                .foregroundStyle(.black)
            }
            .buttonStyle(.glassProminent)
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    let state = AppState()
    state.generatedVariations = [
        AppVariation(name: "V1", previewContent: "<html><body style='background:linear-gradient(135deg,#3B82F6,#1F2937);height:100vh;display:flex;align-items:center;justify-content:center;color:white;font-family:system-ui;'><h1>Preview</h1></body></html>", theme: AppTheme.themes[0])
    ]
    return ThemeSelectionView(appState: state)
}
