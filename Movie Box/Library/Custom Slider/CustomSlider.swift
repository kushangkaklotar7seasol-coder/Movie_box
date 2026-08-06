//
//  CustomSlider.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 05/08/26.
//

import SwiftUI
 
struct CustomGradientSlider: View {
    @Binding var value: Double
    let bounds: ClosedRange<Double>
    let step: Double
    
    let leftColor = LinearGradient(colors: [.grayColour, .grayColour], startPoint: .topLeading, endPoint: .bottomTrailing)
    let rightColor = LinearGradient(colors: [.cyanColour, .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let thumbDiameter: CGFloat = 14
            let trackHeight: CGFloat = 6
            
            // Calculate progress percentage (0.0 to 1.0)
            let percentage = CGFloat((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
            let activeWidth = max(0, min(totalWidth, percentage * totalWidth))
            
            ZStack(alignment: .leading) {
                // 1. Right Side Track (જમણી બાજુનો બેકગ્રાઉન્ડ કલર)
                Capsule()
                    .fill(rightColor)
                    .frame(height: trackHeight)
                
                // 2. Left Side Track (ડાબી બાજુનો એક્ટિવ કલર)
                Capsule()
                    .fill(leftColor)
                    .frame(width: activeWidth, height: trackHeight)
                
                // 3. Thumb (Circle)
                Circle()
                    .fill(rightColor) // જો વર્તુળ પર અલગ કલર કે ગ્રેડિઅન્ટ મૂકવો હોય તો અહીં બદલી શકો છો
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: max(0, min(totalWidth - thumbDiameter, activeWidth - thumbDiameter / 2)))
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let locationX = gesture.location.x
                        let newPercentage = max(0, min(1, locationX / totalWidth))
                        let rawValue = bounds.lowerBound + Double(newPercentage) * (bounds.upperBound - bounds.lowerBound)
                        
                        // Snap to step
                        let steppedValue = (rawValue / step).rounded() * step
                        let clampedValue = max(bounds.lowerBound, min(bounds.upperBound, steppedValue))
                        
                        if value != clampedValue {
                            value = clampedValue
                        }
                    }
            )
        }
        .frame(height: 30)
    }
}
