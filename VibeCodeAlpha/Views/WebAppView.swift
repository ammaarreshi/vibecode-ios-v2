//
//  WebAppView.swift
//  VibeCodeAlpha
//

import SwiftUI
import WebKit

struct WebAppView: View {
    let app: SavedApp
    let onClose: () -> Void
    
    var body: some View {
        ZStack {
            // Web content
            WebView(htmlContent: app.htmlContent)
                .ignoresSafeArea()
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.glass)
                    .tint(.white)
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Web View

struct WebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        // Enable JavaScript
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        
        // Allow JavaScript to run
        webView.configuration.preferences.javaScriptEnabled = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if !htmlContent.isEmpty {
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }
}

#Preview {
    WebAppView(
        app: SavedApp(
            name: "Test",
            iconSymbol: "star.fill",
            iconColor: .blue,
            htmlContent: "<html><body style='background:blue;color:white;display:flex;align-items:center;justify-content:center;height:100vh;'><h1>Hello!</h1></body></html>"
        ),
        onClose: {}
    )
}
