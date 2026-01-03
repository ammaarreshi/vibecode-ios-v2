//
//  ContentView.swift
//  VibeCodeAlpha
//
//  Main navigation router based on flowState
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    
    var body: some View {
        ZStack {
            switch appState.flowState {
            case .homescreen:
                // Always show SavedAppsHomeView - it handles both empty and populated states
                SavedAppsHomeView(appState: appState)
                    .transition(.opacity)
                
            case .recording, .processing:
                // Dedicated recording view for voice input and building
                RecordingView(appState: appState)
                    .transition(.opacity)
                
            case .variations:
                GeneratedAppsView(appState: appState)
                    .transition(.move(edge: .trailing))
                
            case .themes:
                ThemeSelectionView(appState: appState)
                    .transition(.move(edge: .trailing))
                
            case .icons:
                IconSelectionView(appState: appState)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.flowState)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
