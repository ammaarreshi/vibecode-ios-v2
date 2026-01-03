//
//  RecordingView.swift
//  VibeCodeAlpha
//
//  Reusable voice recording and app building view
//  Uses mesh gradient with rim effect from AppHomescreenView
//

import SwiftUI

struct RecordingView: View {
    @Bindable var appState: AppState
    
    @State private var isRecording = false
    @State private var isBuildingMode = false
    @State private var maskTimer: Float = 0.0
    @State private var spinAngle: Double = 0
    @State private var timer: Timer?
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    
    // Building message cycling
    @State private var buildingMessageIndex: Int = 0
    private let buildingMessages = [
        "Cooking up something special...",
        "Writing code so you don't have to...",
        "Sprinkling some magic...",
        "Making it beautiful...",
        "Almost there...",
        "Adding the finishing touches...",
        "Giving up, this is hard...",
        "JK, ha! Got you!...",
        "OK back to building, less jokes...",
        "Creating something amazing..."
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Black background
                Color.black.ignoresSafeArea()
                
                // Animated mesh gradient (always visible in recording view)
                MeshGradientView(maskTimer: $maskTimer, gradientSpeed: .constant(0.03))
                    .scaleEffect(1.3)
                    .ignoresSafeArea()
                
                // Main content masked by animated rectangle
                mainContent
                    .mask {
                        AnimatedRectangle(size: geometry.size, cornerRadius: 48, t: CGFloat(maskTimer))
                            .scaleEffect(1.0)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .blur(radius: 28)
                    }
                
                // Brightness rim around screen
                brightnessRim
            }
            .modifier(RippleEffect(at: origin, trigger: counter))
        }
        .ignoresSafeArea()
        .onAppear {
            startTimer()
            startRecording()
        }
        .onDisappear {
            timer?.invalidate()
            if isRecording {
                appState.stopListening()
            }
        }
        .onChange(of: appState.flowState) { oldValue, newValue in
            // Navigate to variations when generation completes
            if newValue == .variations {
                isBuildingMode = false
                isRecording = false
            }
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
    
    private var mainContent: some View {
        ZStack {
            // Dark scrim
            Rectangle()
                .fill(Color.black)
                .opacity(0.8)
            
            VStack(spacing: 0) {
                // Cancel button
                HStack {
                    Button {
                        cancel()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.medium))
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.glass)
                    .tint(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // Center content
                centerContent
                
                Spacer()
                
                // Mic button
                micButtonView
                    .padding(.bottom, 80)
            }
        }
    }
    
    // MARK: - Center Content
    
    private var centerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isBuildingMode {
                Text(buildingMessages[buildingMessageIndex])
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .id(buildingMessageIndex) // Force view update for transition
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
                    .animation(.easeInOut(duration: 0.4), value: buildingMessageIndex)
            } else {
                Text("Listening...")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                
                if appState.transcribedText.isEmpty {
                    Text("Try saying \"build me a todo app\" or \"create a weather dashboard\"")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(3)
                } else {
                    Text(appState.transcribedText)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.3), value: isBuildingMode)
    }
    
    // MARK: - Mic Button
    
    private var micButtonView: some View {
        Button {
            if !isBuildingMode {
                triggerMicAction()
            }
        } label: {
            Group {
                if isBuildingMode {
                    // Spinning circle during building
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
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
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
        .buttonStyle(.plain)
        .disabled(isBuildingMode)
    }
    
    // MARK: - Actions
    
    private func startRecording() {
        isRecording = true
        Task {
            await appState.startListening()
        }
    }
    
    private func triggerMicAction() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        origin = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 150)
        counter += 1
        
        if isRecording {
            // Stop recording
            isRecording = false
            appState.stopListening()
            
            // Only proceed if we have transcribed text
            if !appState.transcribedText.isEmpty {
                // Start building
                isBuildingMode = true
                startBuildingMessageCycle()
                appState.promptText = appState.transcribedText
                Task {
                    await appState.generateWithGemini()
                }
            } else {
                // No text - go back to homescreen
                appState.resetFlow()
            }
        } else {
            // Start recording again (if they stopped and want to re-record)
            startRecording()
        }
    }
    
    private func cancel() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if isRecording {
            appState.stopListening()
        }
        appState.resetFlow()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            maskTimer += 0.01
        }
    }
    
    private func startBuildingMessageCycle() {
        // Cycle through building messages every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { t in
            if isBuildingMode {
                withAnimation(.easeInOut(duration: 0.4)) {
                    buildingMessageIndex = (buildingMessageIndex + 1) % buildingMessages.count
                }
            } else {
                t.invalidate()
            }
        }
    }
}

#Preview {
    RecordingView(appState: AppState())
}
