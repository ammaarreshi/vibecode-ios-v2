//
//  GeminiService.swift
//  VibeCodeAlpha
//
//  Service for generating web apps using Gemini 3 Flash API
//

import Foundation
import SwiftUI

actor GeminiService {
    static let shared = GeminiService()
    
    private let apiKey = Config.geminiApiKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent"
    
    private init() {}
    
    /// Generates a complete web app HTML based on the user's prompt
    func generateApp(prompt: String, theme: AppTheme?, variationNumber: Int) async throws -> String {
        let systemPrompt = buildSystemPrompt(theme: theme, variationNumber: variationNumber)
        let userPrompt = "Create a web app for: \(prompt)"
        
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": systemPrompt + "\n\n" + userPrompt]]]
            ],
            "generationConfig": [
                "thinkingConfig": [
                    "thinkingLevel": "low"
                ]
            ]
        ]
        
        guard let url = URL(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GeminiError.requestFailed
        }
        
        return try parseResponse(data)
    }
    
    private func buildSystemPrompt(theme: AppTheme?, variationNumber: Int) -> String {
        let themeColors: String
        if let theme = theme {
            themeColors = """
            Use these colors for the design:
            - Primary: \(theme.primaryColor.hexString ?? "#3B82F6")
            - Secondary: \(theme.secondaryColor.hexString ?? "#8B5CF6")
            - Accent: \(theme.accentColor.hexString ?? "#10B981")
            """
        } else {
            let colorSets = [
                ("Primary: #3B82F6", "Secondary: #1E40AF", "Accent: #60A5FA"),
                ("Primary: #8B5CF6", "Secondary: #6D28D9", "Accent: #A78BFA"),
                ("Primary: #10B981", "Secondary: #047857", "Accent: #34D399")
            ]
            let colors = colorSets[(variationNumber - 1) % colorSets.count]
            themeColors = "Use these colors: \(colors.0), \(colors.1), \(colors.2)"
        }
        
        // Randomized creative directions - combine random elements for infinite variety
        let aesthetics = [
            "Bento box grid layout with asymmetric card sizes",
            "Flowing organic shapes with blob morphing animations",
            "Brutalist typography with oversized bold headlines",
            "Neomorphic soft UI with subtle shadows and insets",
            "Retro-futuristic with scanlines and CRT glow effects",
            "Minimalist with dramatic whitespace and single accent",
            "Gradient mesh backgrounds with floating elements",
            "Isometric 3D-style cards with perspective transforms",
            "Magazine editorial layout with mixed media feel",
            "Terminal/hacker aesthetic with monospace and green accents"
        ]
        
        let animations = [
            "Elements fade-scale in with staggered delays",
            "Smooth parallax scrolling effects",
            "Hover states with spring-bounce physics",
            "Subtle floating/breathing animations on key elements",
            "Typewriter text reveal on headings",
            "Cards flip or rotate on interaction",
            "Ripple effects on button clicks",
            "Elastic rubber-band pull interactions"
        ]
        
        let layouts = [
            "Full-screen hero section with scroll-reveal content",
            "Dashboard with multiple interactive widgets",
            "Card-based interface with swipe/drag capability",
            "Split-screen layout with contrasting sections",
            "Vertical timeline or step-by-step flow",
            "Masonry grid with varied content types",
            "Single column focus with floating action buttons"
        ]
        
        // Pick random elements for this variation (use variationNumber as seed variation)
        let aestheticIndex = (variationNumber * 3 + Int.random(in: 0..<aesthetics.count)) % aesthetics.count
        let animIndex = (variationNumber * 5 + Int.random(in: 0..<animations.count)) % animations.count
        let layoutIndex = (variationNumber * 7 + Int.random(in: 0..<layouts.count)) % layouts.count
        
        return """
        You are Flash UI - an ELITE creative web app designer. Generate a COMPLETE, production-quality web application.
        
        **CREATIVE DIRECTION FOR VARIATION \(variationNumber):**
        - Visual Style: \(aesthetics[aestheticIndex])
        - Animation Approach: \(animations[animIndex])
        - Layout Pattern: \(layouts[layoutIndex])
        
        **CRITICAL REQUIREMENTS:**
        1. Return ONLY raw HTML - no markdown, no code fences, no explanations
        2. Start with <!DOCTYPE html> and end with </html>
        3. All CSS in <style> tag, all JS in <script> tag
        4. MUST be fully functional with REAL interactive JavaScript:
           - Buttons must DO something when clicked
           - Forms must handle input
           - Include at least one dynamic/interactive feature
        5. **JAVASCRIPT MUST WORK:** Use DOMContentLoaded, proper event listeners, no syntax errors
        6. Mobile-first, responsive design (use viewport meta tag)
        7. Import a Google Font that matches your aesthetic
        8. Include micro-animations and hover states
        
        \(themeColors)
        
        **MAKE IT UNIQUE:**
        - This is variation \(variationNumber) of 3 - it must look COMPLETELY DIFFERENT from standard templates
        - Be bold and creative with the visual design
        - Surprise the user with interesting interactions
        - Avoid generic bootstrap-style layouts
        
        Start with <!DOCTYPE html> and end with </html>. NO other text.
        """
    }
    
    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.parsingFailed
        }
        
        // Extract HTML from response (in case it's wrapped in markdown)
        return extractHTML(from: text)
    }
    
    private func extractHTML(from text: String) -> String {
        // If it starts with <!DOCTYPE or <html, it's already clean
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("<!DOCTYPE") || trimmed.hasPrefix("<html") {
            return trimmed
        }
        
        // Try to extract from markdown code block
        if let htmlStart = text.range(of: "```html"),
           let htmlEnd = text.range(of: "```", range: htmlStart.upperBound..<text.endIndex) {
            return String(text[htmlStart.upperBound..<htmlEnd.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Try to find DOCTYPE or html tag
        if let doctypeRange = text.range(of: "<!DOCTYPE html>", options: .caseInsensitive) {
            let startIndex = doctypeRange.lowerBound
            if let endRange = text.range(of: "</html>", options: .caseInsensitive, range: startIndex..<text.endIndex) {
                return String(text[startIndex...endRange.upperBound])
            }
        }
        
        // Return as-is if no HTML found
        return text
    }
}

enum GeminiError: Error {
    case invalidURL
    case requestFailed
    case parsingFailed
}

// Extension to get hex string from Color
extension Color {
    var hexString: String? {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
