//
//  PhotoEditViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 30/07/26.
//
import Foundation
import Combine
import _PhotosUI_SwiftUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditViewModel: ObservableObject {
    @Published var isPhtoAvailable: Bool = false
    @Published var selectedItem: PhotosPickerItem? = nil

    /// The pristine, never-modified photo the user picked. NEVER mutate this directly.
    @Published var originalImage: UIImage?
    /// What's currently shown on screen (original + committed filter + committed adjustments).
    @Published var selectedImage: UIImage?

    @Published var isShowCropper: Bool = false

    // MARK: - Filter state
    /// Bound to the UI while the filter sheet is open (live preview value).
    @Published var selectedFilter: String = "Original"
    /// The filter that has actually been saved/confirmed. This is what persists
    /// across opening/closing the sheet.
    private(set) var appliedFilter: String = "Original"
    @Published var isShowFiltes: Bool = false
    /// Base image used while the filter sheet is open = original + committed adjustments
    /// (i.e. everything EXCEPT the filter, so filters never stack on top of each other).
    var tempOriginalImage: UIImage?

    // MARK: - Adjust state (bound to sliders = live preview values)
    @Published var isShowAdjust: Bool = false
    @Published var contrast: Double = 1.0
    @Published var brightness: Double = 0.0
    @Published var dark: Double = 0.0
    @Published var hueAngle: Double = 0.0
    @Published var saturation: Double = 1.0
    @Published var temp: Double = 6500.0
    @Published var vignette: Double = 0.0

    /// Snapshot of the last SAVED adjust values. Restored on Cancel, updated on Save.
    private var committedAdjust = AdjustValues()

    struct AdjustValues {
        var contrast: Double = 1.0
        var brightness: Double = 0.0
        var dark: Double = 0.0
        var hueAngle: Double = 0.0
        var saturation: Double = 1.0
        var temp: Double = 6500.0
        var vignette: Double = 0.0
    }

    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    var adjustDetail: [PersonalDetail] = [PersonalDetail(id: 0, name: "Contrast", value: "ic_constrast"),
                                          PersonalDetail(id: 1, name: "Light", value: "ic_light"),
                                          PersonalDetail(id: 2, name: "Dark", value: "ic_dark"),
                                          PersonalDetail(id: 3, name: "HUE", value: "ic_hue"),
                                          PersonalDetail(id: 4, name: "Saturation", value: "ic_saturation"),
                                          PersonalDetail(id: 5, name: "Temp", value: "ic_temp"),
                                          PersonalDetail(id: 6, name: "Vignette", value: "ic_vignette")]

    let filters = [
        "Original", "Sepia", "Mono", "Noir", "Fade", "Chrome",
        "Vintage", "Dramatic", "Cool", "Warm", "Boost", "Vivid",
        "Vivid Warm", "Vivid Cool", "Process", "Transfer", "Instant",
        "Tonal", "Bloom", "Gloom", "Sharpen", "Crystallize",
        "Pixelate", "Comic", "Edges", "Posterize", "Vignette"
    ]

    // MARK: - Initial photo load

    /// Call this ONCE right after the user picks a photo from PhotosPicker.
    func setInitialImage(_ image: UIImage) {
        originalImage = image
        appliedFilter = "Original"
        selectedFilter = "Original"
        committedAdjust = AdjustValues()
        pushLocalsFromCommitted()
        selectedImage = image
        isPhtoAvailable = true
    }

    // MARK: - Adjust panel

    func openAdjustPanel() {
        // Make sure the sliders reflect exactly what's currently saved.
        pushLocalsFromCommitted()
        isShowAdjust = true
    }

    func cancelAdjust() {
        pushLocalsFromCommitted()
        render()
        isShowAdjust = false
    }

    func saveAdjust() {
        committedAdjust = currentAdjustValues()
        isShowAdjust = false
    }

    /// Called from slider onChange for live preview while dragging.
    func applyAdjustments() {
        render()
    }

    // MARK: - Filter panel

    func openFilterPanel() {
        if !isShowFiltes {
            tempOriginalImage = adjustedOriginal(with: committedAdjust)
            selectedFilter = appliedFilter
        }
        isShowFiltes.toggle()
    }

    func cancelFilter() {
        isShowFiltes = false
        selectedFilter = appliedFilter
        render()
    }

    func saveFilter() {
        appliedFilter = selectedFilter
        isShowFiltes = false
    }

    // MARK: - Reset

    /// Wipes every filter/adjustment and goes back to the exact photo that was picked.
    func resetToOriginal() {
        appliedFilter = "Original"
        selectedFilter = "Original"
        committedAdjust = AdjustValues()
        pushLocalsFromCommitted()
        selectedImage = originalImage
    }

    // MARK: - Rendering (always recomputed from `originalImage` -> no double-apply bugs)

    /// Renders original -> adjustments (live slider values) -> filter (live/committed) and
    /// publishes the result to `selectedImage`.
    private func render() {
        guard let original = originalImage else { return }
        let adjusted = applyAdjustments(to: original, values: currentAdjustValues())
        let filterToUse = isShowFiltes ? selectedFilter : appliedFilter
        selectedImage = applyFilter(adjusted, filter: filterToUse)
    }

    private func adjustedOriginal(with values: AdjustValues) -> UIImage {
        guard let original = originalImage else { return selectedImage ?? UIImage() }
        return applyAdjustments(to: original, values: values)
    }

    private func currentAdjustValues() -> AdjustValues {
        AdjustValues(contrast: contrast, brightness: brightness, dark: dark,
                     hueAngle: hueAngle, saturation: saturation, temp: temp, vignette: vignette)
    }

    private func pushLocalsFromCommitted() {
        contrast = committedAdjust.contrast
        brightness = committedAdjust.brightness
        dark = committedAdjust.dark
        hueAngle = committedAdjust.hueAngle
        saturation = committedAdjust.saturation
        temp = committedAdjust.temp
        vignette = committedAdjust.vignette
    }

    private func applyAdjustments(to inputImage: UIImage, values: AdjustValues) -> UIImage {
        guard let ciImage = CIImage(image: inputImage) else { return inputImage }

        // 1. Color Controls (Contrast, Brightness & Saturation)
        let colorFilter = CIFilter.colorControls()
        colorFilter.inputImage = ciImage
        colorFilter.contrast = Float(values.contrast)
        colorFilter.brightness = Float(values.brightness)
        colorFilter.saturation = Float(values.saturation)

        guard var currentOutput = colorFilter.outputImage else { return inputImage }

        // 2. Dark / Exposure Adjust
        if values.dark != 0.0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = currentOutput
            exposureFilter.ev = Float(values.dark)
            if let output = exposureFilter.outputImage {
                currentOutput = output
            }
        }

        // 3. Hue Adjust
        if values.hueAngle != 0.0 {
            let hueFilter = CIFilter.hueAdjust()
            hueFilter.inputImage = currentOutput
            hueFilter.angle = Float(values.hueAngle)
            if let output = hueFilter.outputImage {
                currentOutput = output
            }
        }

        // 4. Temperature Adjust
        if values.temp != 6500.0 {
            let tempFilter = CIFilter.temperatureAndTint()
            tempFilter.inputImage = currentOutput
            tempFilter.neutral = CIVector(x: 6500, y: 0)
            tempFilter.targetNeutral = CIVector(x: CGFloat(values.temp), y: 0)
            if let output = tempFilter.outputImage {
                currentOutput = output
            }
        }

        // 5. Vignette Adjust
        if values.vignette > 0.0 {
            let vignetteFilter = CIFilter.vignette()
            vignetteFilter.inputImage = currentOutput
            vignetteFilter.intensity = Float(values.vignette)
            vignetteFilter.radius = 1.0
            if let output = vignetteFilter.outputImage {
                currentOutput = output
            }
        }

        guard let cgImage = ciContext.createCGImage(currentOutput, from: currentOutput.extent) else {
            return inputImage
        }
        return UIImage(cgImage: cgImage, scale: inputImage.scale, orientation: inputImage.imageOrientation)
    }

    func applyFilter(_ image: UIImage, filter: String) -> UIImage {
       guard let ciImage = CIImage(image: image) else { return image }

       let context = CIContext()
       var outputImage: CIImage?

       switch filter {
       case "Original":
           return image

       case "Sepia":
           let filter = CIFilter.sepiaTone()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           outputImage = filter.outputImage

       case "Mono":
           let filter = CIFilter.photoEffectMono()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Noir":
           let filter = CIFilter.photoEffectNoir()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Fade":
           let filter = CIFilter.photoEffectFade()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Chrome":
           let filter = CIFilter.photoEffectChrome()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Vintage":
           let filter = CIFilter.photoEffectTransfer()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Dramatic":
           let filter = CIFilter.photoEffectProcess()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Instant":
           let filter = CIFilter.photoEffectInstant()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Tonal":
           let filter = CIFilter.photoEffectTonal()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Cool":
           let filter = CIFilter.temperatureAndTint()
           filter.inputImage = ciImage
           filter.targetNeutral = CIVector(x: 6500, y: 0)
           outputImage = filter.outputImage

       case "Warm":
           let filter = CIFilter.temperatureAndTint()
           filter.inputImage = ciImage
           filter.targetNeutral = CIVector(x: 4500, y: 0)
           outputImage = filter.outputImage

       case "Boost":
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.3
           filter.contrast = 1.1
           filter.brightness = 0.05
           outputImage = filter.outputImage

       case "Vivid":
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.5
           filter.contrast = 1.2
           filter.brightness = 0
           outputImage = filter.outputImage

       case "Vivid Warm":
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.4
           filter.contrast = 1.1
           filter.brightness = 0.05
           outputImage = filter.outputImage
           if let output = outputImage {
               let warmFilter = CIFilter.temperatureAndTint()
               warmFilter.inputImage = output
               warmFilter.targetNeutral = CIVector(x: 5000, y: 0)
               outputImage = warmFilter.outputImage
           }

       case "Vivid Cool":
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.4
           filter.contrast = 1.1
           filter.brightness = 0
           outputImage = filter.outputImage
           if let output = outputImage {
               let coolFilter = CIFilter.temperatureAndTint()
               coolFilter.inputImage = output
               coolFilter.targetNeutral = CIVector(x: 7000, y: 0)
               outputImage = coolFilter.outputImage
           }

       case "Process":
           let filter = CIFilter.photoEffectProcess()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Transfer":
           let filter = CIFilter.photoEffectTransfer()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Bloom":
           let filter = CIFilter.bloom()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           filter.radius = 10
           outputImage = filter.outputImage

       case "Gloom":
           let filter = CIFilter.gloom()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           filter.radius = 10
           outputImage = filter.outputImage

       case "Sharpen":
           let filter = CIFilter.sharpenLuminance()
           filter.inputImage = ciImage
           filter.sharpness = 0.8
           outputImage = filter.outputImage

       case "Crystallize":
           let filter = CIFilter.crystallize()
           filter.inputImage = ciImage
           filter.radius = 15
           outputImage = filter.outputImage

       case "Pixelate":
           let filter = CIFilter.pixellate()
           filter.inputImage = ciImage
           filter.scale = 20
           outputImage = filter.outputImage

       case "Comic":
           let filter = CIFilter.comicEffect()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case "Edges":
           let filter = CIFilter.edges()
           filter.inputImage = ciImage
           filter.intensity = 1.0
           outputImage = filter.outputImage

       case "Posterize":
           let filter = CIFilter.colorPosterize()
           filter.inputImage = ciImage
           filter.levels = 6
           outputImage = filter.outputImage

       case "Vignette":
           let filter = CIFilter.vignette()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           filter.radius = 1.5
           outputImage = filter.outputImage

       default:
           return image
       }

       guard let output = outputImage,
             let cgImage = context.createCGImage(output, from: output.extent) else {
           return image
       }

       return UIImage(cgImage: cgImage)
   }
}
