//
//  ContentView.swift
//  VibeCodeAlpha
//
//  Created by Ammaar Reshi on 1/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    
    var body: some View {
        ZStack {
            switch appState.flowState {
            case .homescreen:
                // When we have saved apps, show the saved apps homescreen
                // Otherwise show the prompting view
                if !appState.savedApps.isEmpty {
                    SavedAppsHomeView(appState: appState)
                        .transition(.opacity)
                } else {
                    AppHomescreenView(appState: appState)
                        .transition(.opacity)
                }
                
            case .recording, .processing:
                // Use dedicated recording view for voice input and building
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
        .animation(.easeInOut(duration: 0.35), value: appState.savedApps.isEmpty)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
