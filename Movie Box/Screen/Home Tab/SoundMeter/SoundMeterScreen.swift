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
                
                ZStack {
                    Gauge(value: Double(viewModel.decibels), in: 0...194) {
                        
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(.greenColour)
                    .scaleEffect(5)
                    .frame(width: screenWidth, height: screenWidth)
                    
                    VStack {
                        VStack {
                            Text("\(viewModel.decibels)")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.whiteColour)
                            
                            Text(Strings.decibles)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.grayColour)
                        }
                    }
                    .frame(width: screenWidth, height: screenWidth)
                }
                
                VStack {
                    SoundMeterDesign.information(Key: Strings.avg, value: "\(viewModel.averageDB)", colour: .whiteColour)
                    
                    HStack {
                        SoundMeterDesign.information(Key: Strings.min, value: "\(viewModel.lowestDB)", colour: .greenColour)
                        SoundMeterDesign.information(Key: Strings.max, value: "\(viewModel.highestDB)", colour: .red)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                HStack {
                    Button {
                        if viewModel.isStarted {
                            viewModel.stopMonitoring()
                        } else {
                            if viewModel.isPermission {
                                viewModel.startMonitoring()
                            } else {
                                viewModel.isShowPermissionAlert = true
                            }
                        }
                    } label: {
                        Text(viewModel.isStarted ? Strings.stop : Strings.start)
                            .font(.system(size: 18, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [viewModel.isStarted ? . clear : .cyanColour, viewModel.isStarted ? . clear : .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(14)
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        LinearGradient(colors: [.cyanColour, .greenColour], startPoint: .top, endPoint: .bottom)
                                    )
                            }
                    }
                    
                    DefaultDesign.FullScreenButton(name: Strings.restart, onClick: {
                        viewModel.dbMeter = []
                        viewModel.highestDB = 0
                        viewModel.lowestDB = 0
                        viewModel.averageDB = 0
                        viewModel.stopMonitoring()
                    }, isDisable: !viewModel.isStarted && viewModel.highestDB == 0 || viewModel.lowestDB == 0)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .alert(Strings.microphoneAccess, isPresented: $viewModel.isShowPermissionAlert) {
            Button(Strings.cancel, role: .cancel) { }
            Button(Strings.openSettings) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(Strings.allowMicrohoneAccess)
        }
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
