//
//  Models.swift
//  VibeCodeAlpha
//

import SwiftUI

// MARK: - Flow State

enum FlowState: Equatable {
    case homescreen
    case recording
    case processing
    case variations
    case themes
    case icons
}

// MARK: - App Variation

struct AppVariation: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var previewContent: String // HTML/CSS/JS for the web app
    var theme: AppTheme
}

// MARK: - App Theme

struct AppTheme: Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var primaryColor: Color
    var secondaryColor: Color
    var accentColor: Color
    var backgroundColor: Color
    
    /// Generates CSS that overrides theme colors in the web app
    var cssOverride: String {
        let primary = primaryColor.toHex() ?? "#3B82F6"
        let secondary = secondaryColor.toHex() ?? "#8B5CF6"
        let accent = accentColor.toHex() ?? "#10B981"
        let bg = backgroundColor.toHex() ?? "#0a0a0a"
        
        return """
        <style id="theme-override">
            :root {
                --primary: \(primary);
                --secondary: \(secondary);
                --accent: \(accent);
                --bg: \(bg);
            }
            body { background: linear-gradient(135deg, \(primary), \(bg)) !important; }
            button, .btn, [class*="button"] { background: \(primary) !important; }
            a, .link { color: \(accent) !important; }
            h1, h2, h3, .title { color: white !important; }
            .card, .panel, [class*="card"] { 
                border-color: \(secondary) !important; 
                box-shadow: 0 0 20px \(primary)33 !important;
            }
        </style>
        """
    }
    
    static let themes: [AppTheme] = [
        AppTheme(name: "Ocean", primaryColor: .blue, secondaryColor: .cyan, accentColor: .teal, backgroundColor: Color(white: 0.1)),
        AppTheme(name: "Sunset", primaryColor: .orange, secondaryColor: .pink, accentColor: .red, backgroundColor: Color(white: 0.1)),
        AppTheme(name: "Forest", primaryColor: .green, secondaryColor: .mint, accentColor: .teal, backgroundColor: Color(white: 0.1)),
        AppTheme(name: "Lavender", primaryColor: .purple, secondaryColor: .indigo, accentColor: .pink, backgroundColor: Color(white: 0.1)),
        AppTheme(name: "Midnight", primaryColor: .indigo, secondaryColor: .purple, accentColor: .blue, backgroundColor: Color(white: 0.05)),
        AppTheme(name: "Rose", primaryColor: .pink, secondaryColor: .red, accentColor: .orange, backgroundColor: Color(white: 0.1)),
    ]
}

// MARK: - App Icon

struct AppIcon: Identifiable, Equatable {
    let id = UUID()
    var symbolName: String
    var backgroundColor: Color
    
    static func generateVariations(for theme: AppTheme) -> [AppIcon] {
        let symbols = ["app.fill", "star.fill", "bolt.fill", "heart.fill", "sparkles", "wand.and.stars", "cpu.fill", "cube.fill", "globe"]
        return symbols.map { symbol in
            AppIcon(symbolName: symbol, backgroundColor: theme.primaryColor)
        }
    }
}

// MARK: - Saved App

struct SavedApp: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var iconSymbol: String
    var iconColorHex: String
    var htmlContent: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, iconSymbol: String, iconColor: Color, htmlContent: String) {
        self.id = id
        self.name = name
        self.iconSymbol = iconSymbol
        self.iconColorHex = iconColor.toHex() ?? "#007AFF"
        self.htmlContent = htmlContent
        self.createdAt = Date()
    }
    
    var iconColor: Color {
        Color(hex: iconColorHex) ?? .blue
    }
}

// MARK: - Color Extensions

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
