//
//  SavedAppsHomeView.swift
//  VibeCodeAlpha
//
//  iOS-style homescreen showing saved apps with mic button
//  Handles both empty state (onboarding) and populated state
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
            
            if appState.savedApps.isEmpty {
                // Empty state - onboarding view
                emptyStateView
            } else {
                // Populated state - app grid
                populatedStateView
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
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Welcome text
            VStack(alignment: .leading, spacing: 12) {
                Text("Vibe code")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("Tap the mic and describe\nthe app you want to create")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Mic button
            MicButton(isRecording: false, isBuildingMode: false) {
                startRecording()
            }
            .padding(.bottom, 64)
        }
    }
    
    // MARK: - Populated State
    
    private var populatedStateView: some View {
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
            
            // Mic button
            MicButton(isRecording: false, isBuildingMode: false) {
                startRecording()
            }
            .padding(.bottom, 50)
        }
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
        appState.flowState = .recording
    }
}

#Preview {
    let state = AppState()
    return SavedAppsHomeView(appState: state)
}
