//
//  RotaryDial.swift
//  VibeCodeAlpha
//
//  Rotary dial selector with continuous rotation feel
//  Used for selecting between app variations
//

import SwiftUI

struct RotaryDial: View {
    let itemCount: Int
    @Binding var selectedIndex: Int
    
    private let dialWidth: CGFloat = 320
    private let tickCount: Int = 60
    
    @State private var rotationOffset: CGFloat = 0
    @State private var lastDragValue: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Tick marks with upward curve (smile)
            ForEach(0..<tickCount, id: \.self) { index in
                tickMark(at: index)
            }
            
            // Needle indicator (fixed center)
            needleView
        }
        .frame(width: dialWidth, height: 50)
        .mask {
            // Fade edges
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white, location: 0.15),
                    .init(color: .white, location: 0.85),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .gesture(dialGesture)
    }
    
    private func tickMark(at index: Int) -> some View {
        // Calculate position with rotation offset for infinite scroll feel
        let baseT = CGFloat(index) / CGFloat(tickCount - 1)
        let offsetT = baseT + rotationOffset / dialWidth
        let wrappedT = offsetT.truncatingRemainder(dividingBy: 1.0)
        let t = wrappedT < 0 ? wrappedT + 1 : wrappedT
        
        let x = t * dialWidth
        
        // Upward curve (highest in center)
        let normalizedX = (t - 0.5) * 2
        let curveAmount: CGFloat = 25
        let y: CGFloat = 40 - (curveAmount * (1 - normalizedX * normalizedX))
        
        let isLong = index % 6 == 0
        let height: CGFloat = isLong ? 12 : 7
        let width: CGFloat = isLong ? 1.5 : 1
        
        // Highlight near center (where needle is)
        let distanceFromCenter = abs(t - 0.5)
        let isHighlighted = distanceFromCenter < 0.05
        
        return Rectangle()
            .fill(isHighlighted ? Color.yellow : Color.white.opacity(0.4))
            .frame(width: width, height: height)
            .position(x: x, y: y - height / 2)
            .shadow(color: isHighlighted ? .yellow.opacity(0.6) : .clear, radius: 3)
    }
    
    private var needleView: some View {
        // Fixed center needle
        let t: CGFloat = 0.5
        let x = t * dialWidth
        let curveAmount: CGFloat = 25
        let y: CGFloat = 40 - curveAmount
        
        return VStack(spacing: 0) {
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: 20)
            Circle()
                .fill(Color.red)
                .frame(width: 5, height: 5)
        }
        .position(x: x, y: y - 10)
    }
    
    private var dialGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let delta = value.translation.width - lastDragValue
                lastDragValue = value.translation.width
                
                // Rotate based on drag delta (more sensitive)
                rotationOffset += delta * 0.5
                
                // Calculate new index based on accumulated rotation
                let ticksPerItem = CGFloat(tickCount) / CGFloat(max(1, itemCount))
                let rotatedTicks = -rotationOffset / (dialWidth / CGFloat(tickCount))
                let newIndex = Int(round(rotatedTicks / ticksPerItem))
                let clampedIndex = ((newIndex % itemCount) + itemCount) % itemCount
                
                if clampedIndex != selectedIndex && itemCount > 0 {
                    UISelectionFeedbackGenerator().selectionChanged()
                    selectedIndex = clampedIndex
                }
            }
            .onEnded { value in
                lastDragValue = 0
                
                // Smooth snap animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    // Snap to nearest item position
                    let ticksPerItem = CGFloat(tickCount) / CGFloat(max(1, itemCount))
                    let targetTicks = CGFloat(selectedIndex) * ticksPerItem
                    rotationOffset = -targetTicks * (dialWidth / CGFloat(tickCount))
                }
            }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RotaryDial(itemCount: 3, selectedIndex: .constant(1))
    }
}
