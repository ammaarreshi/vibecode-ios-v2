//
//  ArcDialSelector.swift
//  VibeCodeAlpha
//

import SwiftUI

struct ArcDialSelector: View {
    let itemCount: Int
    @Binding var selectedIndex: Int
    var onSelectionChanged: ((Int) -> Void)? = nil
    
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging = false
    
    private let arcRadius: CGFloat = 120
    private let pipSize: CGFloat = 12
    private let selectedPipSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Arc track
            ArcShape(startAngle: .degrees(160), endAngle: .degrees(20))
                .stroke(Color.white.opacity(0.2), lineWidth: 3)
                .frame(width: arcRadius * 2, height: arcRadius)
            
            // Pips
            ForEach(0..<itemCount, id: \.self) { index in
                pipView(for: index)
                    .position(pipPosition(for: index))
            }
        }
        .frame(width: arcRadius * 2 + 40, height: arcRadius + 40)
        .gesture(dragGesture)
    }
    
    private func pipView(for index: Int) -> some View {
        let isSelected = index == selectedIndex
        
        return Circle()
            .fill(isSelected ? Color.white : Color.white.opacity(0.5))
            .frame(
                width: isSelected ? selectedPipSize : pipSize,
                height: isSelected ? selectedPipSize : pipSize
            )
            .glassEffect(isSelected ? .regular.interactive() : .regular, in: .circle)
            .scaleEffect(isSelected ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIndex)
            .onTapGesture {
                selectItem(at: index)
            }
    }
    
    private func pipPosition(for index: Int) -> CGPoint {
        let totalAngle: CGFloat = 140 // degrees from 160 to 20
        let startAngle: CGFloat = 160
        
        let angleStep = totalAngle / CGFloat(max(itemCount - 1, 1))
        let angle = startAngle - (angleStep * CGFloat(index))
        let radians = angle * .pi / 180
        
        let x = arcRadius + cos(radians) * arcRadius + 20
        let y = arcRadius - sin(radians) * arcRadius + 20
        
        return CGPoint(x: x, y: y)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { value in
                let newOffset = value.translation.width
                let delta = newOffset - dragOffset
                
                // Map horizontal drag to selection
                if abs(delta) > 30 {
                    let direction = delta > 0 ? -1 : 1
                    let newIndex = selectedIndex + direction
                    
                    if newIndex >= 0 && newIndex < itemCount {
                        selectItem(at: newIndex)
                    }
                    dragOffset = newOffset
                }
            }
            .onEnded { _ in
                dragOffset = 0
            }
    }
    
    private func selectItem(at index: Int) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        selectedIndex = index
        onSelectionChanged?(index)
    }
}

// MARK: - Arc Shape

struct ArcShape: Shape {
    var startAngle: Angle
    var endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height * 2) / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        
        return path
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        ArcDialSelector(itemCount: 3, selectedIndex: .constant(1))
    }
}
