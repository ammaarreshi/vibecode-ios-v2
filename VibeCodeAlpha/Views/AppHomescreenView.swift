//
//  AppHomescreenView.swift
//  VibeCodeAlpha
//
//  Seamless homescreen with Siri-style animations that flows into voice recording
//

import SwiftUI

struct AppHomescreenView: View {
    @Bindable var appState: AppState
    @State private var selectedApp: SavedApp? = nil
    @State private var isJiggling = false
    @State private var showDeleteAlert = false
    @State private var appToDelete: SavedApp? = nil
    
    // Animation states - shared between homescreen and recording
    @State private var isRecordingMode = false
    @State private var isBuildingMode = false
    @State private var counter: Int = 0
    @State private var origin: CGPoint = .init(x: 0.5, y: 0.5)
    @State private var maskTimer: Float = 0.0
    @State private var timer: Timer?
    
    // Cycling text for app ideas
    @State private var currentIdeaIndex = 0
    @State private var showIdea = true
    @State private var spinAngle: Double = 0
    
    private let appIdeas = [
        "A habit tracker",
        "A recipe finder",
        "A workout timer",
        "A mood journal",
        "A budget planner",
        "A meditation guide",
        "A todo list",
        "A weather dashboard"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base black background
                Color.black.ignoresSafeArea()
                
                // Animated mesh gradient as background (always visible at full opacity)
                MeshGradientView(maskTimer: $maskTimer, gradientSpeed: .constant(0.03))
                    .scaleEffect(1.3)
                    .ignoresSafeArea()
                
                // Simple content overlay - no mask, no scrim for clean idle state
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Cycling ideas text
                    centerContent
                    
                    Spacer()
                    
                    // Mic button at bottom
                    micButtonView
                        .padding(.bottom, 64)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onPressingChanged { point in
                    if let point {
                        origin = point
                        counter += 1
                    }
                }
            }
        }
        .ignoresSafeArea()
        .modifier(RippleEffect(at: origin, trigger: counter))
        .onAppear {
            startTimer()
            startIdeaCycling()
        }
        .onDisappear {
            timer?.invalidate()
        }
        // Reset local states when returning to homescreen from other flows
        .onChange(of: appState.flowState) { oldValue, newValue in
            if newValue == .homescreen && oldValue != .homescreen {
                // Coming back from save flow - reset recording/building modes
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRecordingMode = false
                    isBuildingMode = false
                    spinAngle = 0
                }
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
    
    // MARK: - Brightness Rim
    
    private var brightnessRim: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 10))
                .blur(radius: 5)
                .blendMode(.overlay)
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 10))
                .blur(radius: 10)
                .blendMode(.softLight)
            RoundedRectangle(cornerRadius: 52, style: .continuous)
                .stroke(Color.white, style: .init(lineWidth: 5))
                .blur(radius: 2)
                .blendMode(.overlay)
        }
    }
    
    // MARK: - Main Content
    
    private func mainContent(geometry: GeometryProxy) -> some View {
        ZStack {
            // Dark scrim
            Rectangle()
                .fill(Color.black)
                .opacity((isRecordingMode || isBuildingMode) ? 0.8 : 0)
            
            VStack(spacing: 0) {
                // When recording/building, show that UI
                // When there are saved apps, show iOS-style homescreen grid
                // When no apps, show the cycling ideas prompt
                
                if isRecordingMode || isBuildingMode {
                    Spacer()
                    centerContent
                    Spacer()
                } else if !appState.savedApps.isEmpty {
                    // iOS-style homescreen with app grid
                    homescreenGrid(geometry: geometry)
                } else {
                    // No saved apps - show cycling ideas to prompt user
                    Spacer()
                    centerContent
                    Spacer()
                }
                
                // Mic button always at bottom
                micButtonView
                    .padding(.bottom, 64)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onPressingChanged { point in
                if let point {
                    origin = point
                    counter += 1
                }
            }
        }
    }
    
    // MARK: - Homescreen Grid (iOS-style)
    
    private func homescreenGrid(geometry: GeometryProxy) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(appState.savedApps) { app in
                    AppIconButton(
                        app: app,
                        isJiggling: isJiggling,
                        onTap: { openApp(app) },
                        onDelete: {
                            appToDelete = app
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 80) // Safe area for status bar
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Center Content
    
    private var centerContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isBuildingMode {
                // Building state
                Text("Building your app...")
                    .customAttribute(EmphasisAttribute())
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
                    .transition(TextTransition())
            } else if isRecordingMode {
                // Recording - show live transcription with hints
                VStack(alignment: .leading, spacing: 16) {
                    Text("Listening...")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    // Live transcribed text or hint
                    if appState.transcribedText.isEmpty {
                        Text("Try saying \"build me a todo app\" or \"create a weather dashboard\"")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(3)
                    } else {
                        Text(appState.transcribedText)
                            .customAttribute(EmphasisAttribute())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(5)
                            .transition(TextTransition())
                    }
                }
            } else {
                // Cycling app ideas
                Text("Vibe code")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.white)
                
                if showIdea {
                    Text(appIdeas[currentIdeaIndex])
                        .customAttribute(EmphasisAttribute())
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .transition(TextTransition())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.3), value: isRecordingMode)
        .animation(.easeInOut(duration: 0.3), value: isBuildingMode)
    }
    
    // MARK: - Mic Button (Siri-style)
    
    private var micButtonView: some View {
        Button {
            if !isBuildingMode {
                triggerMicAction()
            }
        } label: {
            Group {
                if isBuildingMode {
                    // Custom spinning circle (ProgressView can show X on some iOS)
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(spinAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                spinAngle = 360
                            }
                        }
                } else {
                    Image(systemName: isRecordingMode ? "stop.fill" : "mic.fill")
                        .contentTransition(.symbolEffect(.replace))
                }
            }
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
        .disabled(isBuildingMode)
    }
    
    // MARK: - Actions
    
    private func triggerMicAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.9)) {
            if isRecordingMode {
                // Stop recording, show building state
                appState.stopListening()
                isRecordingMode = false
                isBuildingMode = true
                
                // Trigger real generation with Gemini
                Task {
                    await appState.generateWithGemini()
                    await MainActor.run {
                        isBuildingMode = false
                    }
                }
            } else {
                // Start recording with speech recognition
                isRecordingMode = true
                appState.flowState = .recording
                Task {
                    await appState.startListening()
                }
            }
        }
    }
    
    private func openApp(_ app: SavedApp) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        selectedApp = app
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            DispatchQueue.main.async {
                if isRecordingMode || isBuildingMode {
                    maskTimer += 0.03
                }
            }
        }
    }
    
    private func startIdeaCycling() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            guard !isRecordingMode else { return }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                showIdea = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                currentIdeaIndex = (currentIdeaIndex + 1) % appIdeas.count
                withAnimation(.easeInOut(duration: 0.3)) {
                    showIdea = true
                }
            }
        }
    }
}

// MARK: - App Icon Button

struct AppIconButton: View {
    let app: SavedApp
    let isJiggling: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var jiggleRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                ZStack(alignment: .topTrailing) {
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
                    
                    if isJiggling {
                        Button(action: onDelete) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 22, height: 22)
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .offset(x: 6, y: -6)
                    }
                }
            }
            .buttonStyle(AppIconButtonStyle())
            .rotationEffect(.degrees(isJiggling ? jiggleRotation : 0))
            
            Text(app.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(width: 80)
        .onAppear { if isJiggling { startJiggle() } }
    }
    
    private func startJiggle() {
        withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
            jiggleRotation = 2
        }
    }
}

struct AppIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    let state = AppState()
    state.savedApps = [
        SavedApp(name: "Weather", iconSymbol: "cloud.sun.fill", iconColor: .blue, htmlContent: ""),
        SavedApp(name: "Notes", iconSymbol: "note.text", iconColor: .yellow, htmlContent: ""),
    ]
    return AppHomescreenView(appState: state)
}
