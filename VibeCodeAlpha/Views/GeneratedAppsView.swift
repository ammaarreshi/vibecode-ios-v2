//
//  GeneratedAppsView.swift
//  VibeCodeAlpha
//
//  3D carousel view for browsing generated app variations
//

import SwiftUI
import WebKit

struct GeneratedAppsView: View {
    @Bindable var appState: AppState
    @Namespace private var namespace
    
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    @State private var showFullscreenPreview = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    header
                        .padding(.top, 16)
                    
                    // Full-screen 3D carousel preview
                    carouselView(geometry: geometry)
                        .frame(maxHeight: .infinity)
                    
                    // Bottom dial and controls
                    bottomSection
                        .padding(.bottom, 24)
                }
                
                // Side buttons (floating)
                sideButtons
            }
        }
        .fullScreenCover(isPresented: $showFullscreenPreview) {
            FullscreenPreviewView(
                htmlContent: appState.currentVariation?.previewContent ?? "",
                onClose: { showFullscreenPreview = false }
            )
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        Text("Customize your app")
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }
    
    // MARK: - 3D Carousel
    
    private func carouselView(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        let cardWidth = screenWidth - 40
        let cardHeight = geometry.size.height * 0.65
        
        return ZStack {
            ForEach(Array(appState.generatedVariations.enumerated()), id: \.element.id) { index, variation in
                let offset = CGFloat(index - appState.selectedVariationIndex)
                let adjustedOffset = offset + dragOffset / (cardWidth * 0.5)
                
                carouselCard(
                    variation: variation,
                    offset: adjustedOffset,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight
                )
            }
        }
        .gesture(carouselDragGesture(cardWidth: cardWidth))
    }
    
    private func carouselCard(variation: AppVariation, offset: CGFloat, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        // 3D rotation and scaling based on offset
        let rotation = Double(offset) * 45
        let scale = 1.0 - abs(offset) * 0.2
        let xOffset = offset * cardWidth * 0.7
        let opacity = 1.0 - abs(offset) * 0.5
        let zIndex = 1.0 - abs(offset)
        
        return WebPreviewView(htmlContent: variation.previewContent)
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: appState.selectedTheme.primaryColor.opacity(0.3), radius: 30, y: 15)
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .scaleEffect(max(0.5, scale))
            .offset(x: xOffset)
            .opacity(max(0, opacity))
            .zIndex(zIndex)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.selectedVariationIndex)
    }
    
    private func carouselDragGesture(cardWidth: CGFloat) -> some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let threshold = cardWidth * 0.2
                var newIndex = appState.selectedVariationIndex
                
                if value.translation.width < -threshold {
                    newIndex = min(appState.generatedVariations.count - 1, appState.selectedVariationIndex + 1)
                } else if value.translation.width > threshold {
                    newIndex = max(0, appState.selectedVariationIndex - 1)
                }
                
                if newIndex != appState.selectedVariationIndex {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.selectedVariationIndex = newIndex
                    dragOffset = 0
                }
            }
    }
    
    // MARK: - Side Buttons
    
    private var sideButtons: some View {
        HStack {
            // Left side buttons
            VStack(spacing: 12) {
                SideActionButton(icon: "paintpalette.fill") {
                    appState.proceedToThemes()
                }
                SideActionButton(icon: "folder.fill") { }
                SideActionButton(icon: "chevron.left.forwardslash.chevron.right") { }
            }
            .padding(.leading, 12)
            
            Spacer()
            
            // Right side button - Maximize preview
            VStack {
                SideActionButton(icon: "arrow.up.left.and.arrow.down.right") {
                    showFullscreenPreview = true
                }
            }
            .padding(.trailing, 12)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    // MARK: - Bottom Section
    
    private var bottomSection: some View {
        VStack(spacing: 20) {
            // Rotary dial selector
            RotaryDial(
                itemCount: appState.generatedVariations.count,
                selectedIndex: $appState.selectedVariationIndex
            )
            
            // Bottom action row
            bottomActionRow
        }
    }
    
    private var bottomActionRow: some View {
        HStack {
            // Cancel button
            Button {
                appState.resetFlow()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.medium))
                    .frame(width: 52, height: 52)
            }
            .buttonStyle(.glass)
            .tint(.white)
            
            Spacer()
            
            // Variation indicator
            ZStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 44, height: 44)
                
                Text("\(appState.selectedVariationIndex + 1)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.black)
            }
            
            Spacer()
            
            // Confirm button
            Button {
                appState.proceedToIcons()
            } label: {
                Image(systemName: "checkmark")
                    .font(.title3.weight(.medium))
                    .frame(width: 52, height: 52)
                    .foregroundStyle(.black)
            }
            .buttonStyle(.glassProminent)
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Web Preview

struct WebPreviewView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// MARK: - Fullscreen Preview View

struct FullscreenPreviewView: View {
    let htmlContent: String
    let onClose: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Full screen web view
            WebView(htmlContent: htmlContent)
                .ignoresSafeArea()
            
            // Close button
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.glass)
            .padding(.top, 60)
            .padding(.leading, 20)
        }
        .background(Color.black)
    }
}

#Preview {
    let state = AppState()
    state.generatedVariations = [
        AppVariation(name: "V1", previewContent: "<html><body style='background:linear-gradient(135deg,#00ff87,#60efff);height:100vh;'></body></html>", theme: AppTheme.themes[0]),
        AppVariation(name: "V2", previewContent: "<html><body style='background:linear-gradient(135deg,#ff6b6b,#feca57);height:100vh;'></body></html>", theme: AppTheme.themes[1]),
        AppVariation(name: "V3", previewContent: "<html><body style='background:linear-gradient(135deg,#a55eea,#45aaf2);height:100vh;'></body></html>", theme: AppTheme.themes[2]),
    ]
    return GeneratedAppsView(appState: state)
}
