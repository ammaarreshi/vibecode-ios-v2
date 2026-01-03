//
//  SavedAppsHomeView.swift
//  VibeCodeAlpha
//
//  iOS-style homescreen showing saved apps with mic button
//  Tapping mic navigates to RecordingView via flowState
//

import SwiftUI

struct SavedAppsHomeView: View {
    @Bindable var appState: AppState
    @State private var selectedApp: SavedApp? = nil
    @State private var showDeleteAlert = false
    @State private var appToDelete: SavedApp? = nil
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // App grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(appState.savedApps) { app in
                            AppIconView(
                                app: app,
                                onTap: { openApp(app) },
                                onLongPress: {
                                    appToDelete = app
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 120)
                }
                
                Spacer()
                
                // Mic button - navigates to RecordingView
                micButtonView
                    .padding(.bottom, 50)
            }
        }
        .fullScreenCover(item: $selectedApp) { app in
            WebAppView(app: app) { selectedApp = nil }
        }
        .alert("Delete App?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let app = appToDelete { appState.deleteApp(app) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(appToDelete?.name ?? "this app")\".")
        }
    }
    
    // MARK: - Mic Button
    
    private var micButtonView: some View {
        Button {
            startRecording()
        } label: {
            Image(systemName: "mic.fill")
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
    }
    
    // MARK: - Actions
    
    private func openApp(_ app: SavedApp) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        selectedApp = app
    }
    
    private func startRecording() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // Navigate to RecordingView via flowState change
        appState.flowState = .recording
    }
}

// MARK: - App Icon View

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
    let state = AppState()
    return SavedAppsHomeView(appState: state)
}
