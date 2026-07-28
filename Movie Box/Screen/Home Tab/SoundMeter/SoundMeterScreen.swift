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
                DefaultDesign.Header(name: Strings.soundMeter)
                    .padding(.horizontal, 16)
                
                VStack {
                    Gauge(value: Double(viewModel.decibels), in: 0...194) {
                        VStack {
                            Text("\(viewModel.decibels)")
                                .font(.system(size: 7, weight: .medium))
                                .foregroundColor(.whiteColour)
                            
                            Text(Strings.decibles)
                                .font(.system(size: 4, weight: .semibold))
                                .foregroundColor(.grayColour)
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.greenColour)
                    .scaleEffect(5)
                    .frame(width: screenWidth, height: screenWidth)
                }
                
                Spacer()
                
                VStack {
                    SoundMeterDesign.information(Key: Strings.avg, value: "\(viewModel.averageDB)", colour: .whiteColour)
                    
                    HStack {
                        SoundMeterDesign.information(Key: Strings.min, value: "\(viewModel.lowestDB)", colour: .greenColour)
                        SoundMeterDesign.information(Key: Strings.max, value: "\(viewModel.highestDB)", colour: .red)
                    }
                }
                .padding(.horizontal, 16)
                
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

class SoundMeterDesign {
    
    struct information: View {
        let Key: String
        let value: String
        let colour: Color
        
        var body: some View {
            HStack {
                Spacer()
                
                VStack(spacing: 5) {
                    Text(Key)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.whiteColour)
                    
                    Text(value)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(colour)
                }
                
                Spacer()
            }
            .padding()
            .background(.backgroundColour)
            .cornerRadius(18)
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(.whiteColour.opacity(0.1))
            }
        }
    }
}
