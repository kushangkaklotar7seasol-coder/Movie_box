//
//  SoundMeterViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import Foundation
internal import Combine
import AVFoundation
import SwiftUI

class SoundMeterViewModel: ObservableObject {
    private var audioEngine = AVAudioEngine()
    @Published var decibels: Float = 0.0
    @Published var isPermission: Bool = false
    
    init() {
        self.requestMicrophonePermission()
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            self.isPermission = granted
            if granted {
                self.startMonitoring()
            }
        }
    }
    
    func startMonitoring() {
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            let level = self.getSoundLevel(buffer: buffer)
            DispatchQueue.main.async {
                self.decibels = level
            }
        }
        
        try? audioEngine.start()
    }
    
    func stopMonitoring() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func getSoundLevel(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let channelDataArray = Array(UnsafeBufferPointer(start: channelData[0], count: Int(buffer.frameLength)))
        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength) + Float.ulpOfOne)
        let level = 20 * log10(rms)
        return max(level + 100, 0) // Normalize value
    }
}
