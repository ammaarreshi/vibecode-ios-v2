//
//  IconSelectionView.swift
//  VibeCodeAlpha
//
//  Icon selection and app naming screen with Liquid Glass styling
//

import SwiftUI

struct IconSelectionView: View {
    @Bindable var appState: AppState
    @State private var iconVariations: [AppIcon] = []
    @FocusState private var isNameFieldFocused: Bool
    
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
                    
                    // Selected icon preview
                    selectedIconPreview
                    
                    // App name input
                    appNameInput
                        .padding(.vertical, 32)
                    
                    // Icon grid
                    IconGridView(
                        icons: iconVariations,
                        selectedIcon: Binding(
                            get: { appState.selectedIcon },
                            set: { appState.selectedIcon = $0 }
                        )
                    )
                    
                    Spacer()
                    
                    // Bottom action row
                    bottomActionRow
                        .padding(.bottom, 40)
                }
            }
            .onTapGesture {
                isNameFieldFocused = false
            }
        }
        .onAppear {
            iconVariations = AppIcon.generateVariations(for: appState.selectedTheme)
            if appState.selectedIcon == nil {
                appState.selectedIcon = iconVariations.first
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        Text("App Icon")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    // MARK: - Selected Icon Preview
    
    private var selectedIconPreview: some View {
        Group {
            if let icon = appState.selectedIcon {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [icon.backgroundColor, icon.backgroundColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.5), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .overlay {
                            Image(systemName: icon.symbolName)
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: icon.backgroundColor.opacity(0.5), radius: 20, y: 10)
                }
            }
        }
    }
    
    // MARK: - App Name Input
    
    private var appNameInput: some View {
        VStack(spacing: 8) {
            Text("App Name")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            
            TextField("My App", text: $appState.appName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white.opacity(0.1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        }
                }
                .frame(maxWidth: 280)
                .focused($isNameFieldFocused)
        }
    }
    
    // MARK: - Bottom Actions
    
    private var bottomActionRow: some View {
        HStack {
            // Back button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.flowState = .themes
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.medium))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.glass)
            .tint(.white)
            
            Spacer()
            
            // Save button
            Button {
                saveApp()
            } label: {
                HStack(spacing: 8) {
                    Text("Save")
                        .font(.headline)
                    Image(systemName: "checkmark")
                }
                .frame(height: 52)
                .padding(.horizontal, 24)
                .foregroundStyle(.black)
            }
            .buttonStyle(.glassProminent)
            .disabled(appState.selectedIcon == nil)
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Actions
    
    private func saveApp() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Save the app - this sets flowState to .homescreen
        appState.saveApp()
    }
}

#Preview {
    let state = AppState()
    state.selectedTheme = AppTheme.themes[0]
    return IconSelectionView(appState: state)
}
