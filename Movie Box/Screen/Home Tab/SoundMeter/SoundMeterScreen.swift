//
//  SoundMeterScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import SwiftUI

struct SoundMeterScreen: View {
    @StateObject var viewModel = SoundMeterViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Sound Meter")
                
                CircularProgressView(progress: Double(viewModel.decibels))
                
                Text("\(viewModel.decibels) DB")
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
    }
}

#Preview {
    SoundMeterScreen()
}

struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 20
    var trackColor: Color = Color(.systemGray6)
    var progressColor: Color = .blue
    
    var body: some View {
        ZStack {
            // Background track ring
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            // Filling progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                // Rotates the circle start point from 3 o'clock to 12 o'clock
                .rotationEffect(Angle(degrees: -90))
        }
    }
}
