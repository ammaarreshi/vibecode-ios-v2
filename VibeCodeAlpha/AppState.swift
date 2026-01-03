//
//  AppState.swift
//  VibeCodeAlpha
//

import SwiftUI

@Observable
class AppState {
    // MARK: - Flow
    var flowState: FlowState = .homescreen
    var promptText: String = ""
    
    // MARK: - Speech Recognition
    let speechRecognizer = SpeechRecognizer()
    
    // MARK: - Generation
    var generatedVariations: [AppVariation] = []
    var selectedVariationIndex: Int = 0
    var isGenerating: Bool = false
    var generationError: String?
    
    // MARK: - Selection
    var selectedTheme: AppTheme = AppTheme.themes[0]
    var selectedIcon: AppIcon? = nil
    var appName: String = "My App"
    
    // MARK: - Saved Apps (persisted)
    var savedApps: [SavedApp] = [] {
        didSet {
            saveToDisk()
        }
    }
    
    private static let savedAppsKey = "SavedApps"
    
    init() {
        loadFromDisk()
    }
    
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedApps) {
            UserDefaults.standard.set(encoded, forKey: Self.savedAppsKey)
        }
    }
    
    private func loadFromDisk() {
        if let data = UserDefaults.standard.data(forKey: Self.savedAppsKey),
           let decoded = try? JSONDecoder().decode([SavedApp].self, from: data) {
            savedApps = decoded
        }
    }
    
    // MARK: - Computed
    var currentVariation: AppVariation? {
        guard !generatedVariations.isEmpty, selectedVariationIndex < generatedVariations.count else { return nil }
        return generatedVariations[selectedVariationIndex]
    }
    
    var transcribedText: String {
        speechRecognizer.transcribedText
    }
    
    // MARK: - Speech Actions
    
    func startListening() async {
        let authorized = await speechRecognizer.requestPermissions()
        if authorized {
            speechRecognizer.startRecording()
        }
    }
    
    func stopListening() {
        speechRecognizer.stopRecording()
        promptText = speechRecognizer.transcribedText
    }
    
    // MARK: - Generation Actions
    
    func startRecording() {
        flowState = .recording
    }
    
    /// Generate 3 app variations using Gemini
    func generateWithGemini() async {
        guard !promptText.isEmpty else { return }
        
        isGenerating = true
        generationError = nil
        flowState = .processing
        
        var variations: [AppVariation] = []
        
        // Generate 3 variations concurrently
        var results: [(Int, AppVariation)] = []
        
        await withTaskGroup(of: (Int, String?).self) { group in
            for i in 1...3 {
                group.addTask {
                    do {
                        let html = try await GeminiService.shared.generateApp(
                            prompt: self.promptText,
                            theme: nil,
                            variationNumber: i
                        )
                        return (i, html)
                    } catch {
                        print("Generation error for variation \(i): \(error)")
                        return (i, nil)
                    }
                }
            }
            
            for await (index, html) in group {
                if let html = html {
                    let variation = AppVariation(
                        name: "Variation \(index)",
                        previewContent: html,
                        theme: AppTheme.themes[(index - 1) % AppTheme.themes.count]
                    )
                    results.append((index, variation))
                }
            }
        }
        
        // Sort by index and extract variations
        let sortedVariations = results
            .sorted { $0.0 < $1.0 }
            .map { $0.1 }
        
        await MainActor.run {
            if sortedVariations.isEmpty {
                generationError = "Failed to generate apps. Please try again."
                flowState = .homescreen
            } else {
                generatedVariations = sortedVariations
                flowState = .variations
            }
            selectedVariationIndex = 0
            isGenerating = false
        }
    }
    
    /// For backward compatibility - calls the new async method
    func simulateGeneration() {
        Task {
            await generateWithGemini()
        }
    }
    
    // MARK: - Theme Application
    
    /// Apply theme to ALL variations by injecting CSS override (instant, no regeneration)
    func applyThemeToAllVariations() {
        let cssOverride = selectedTheme.cssOverride
        
        for i in 0..<generatedVariations.count {
            var html = generatedVariations[i].previewContent
            
            // Remove any existing theme override
            if let overrideStart = html.range(of: "<style id=\"theme-override\">"),
               let overrideEnd = html.range(of: "</style>", range: overrideStart.upperBound..<html.endIndex) {
                html.removeSubrange(overrideStart.lowerBound...overrideEnd.upperBound)
            }
            
            // Inject new theme CSS after <head>
            if let headEnd = html.range(of: "<head>") {
                html.insert(contentsOf: "\n" + cssOverride, at: headEnd.upperBound)
            } else if let bodyStart = html.range(of: "<body") {
                // Fallback: inject before body
                html.insert(contentsOf: cssOverride + "\n", at: bodyStart.lowerBound)
            }
            
            generatedVariations[i] = AppVariation(
                name: generatedVariations[i].name,
                previewContent: html,
                theme: selectedTheme
            )
        }
    }
    
    /// For compatibility - calls the sync method
    func applyThemeToCurrentVariation() async {
        await MainActor.run {
            applyThemeToAllVariations()
        }
    }
    
    // MARK: - Navigation
    
    func selectVariation(at index: Int) {
        guard index < generatedVariations.count else { return }
        selectedVariationIndex = index
    }
    
    func proceedToThemes() {
        flowState = .themes
    }
    
    func proceedToIcons() {
        selectedIcon = AppIcon.generateVariations(for: selectedTheme).first
        flowState = .icons
    }
    
    func saveApp() {
        guard let icon = selectedIcon else { return }
        
        let app = SavedApp(
            name: appName,
            iconSymbol: icon.symbolName,
            iconColor: icon.backgroundColor,
            htmlContent: currentVariation?.previewContent ?? ""
        )
        savedApps.append(app)
        
        resetFlow()
    }
    
    func resetFlow() {
        flowState = .homescreen
        promptText = ""
        generatedVariations = []
        selectedVariationIndex = 0
        selectedTheme = AppTheme.themes[0]
        selectedIcon = nil
        appName = "My App"
        generationError = nil
    }
    
    func deleteApp(_ app: SavedApp) {
        savedApps.removeAll { $0.id == app.id }
    }
}

