import Foundation
import Combine
import _PhotosUI_SwiftUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditViewModel: ObservableObject {
    @Published var isPhtoAvailable: Bool = false
    @Published var selectedItem: PhotosPickerItem? = nil

    @Published var originalImage: UIImage?
    @Published var selectedImage: UIImage?

    @Published var isShowCropper: Bool = false
    @Published var isShowPhotoPicker: Bool = false

    // MARK: - Filter state
    @Published var selectedFilter: String = Strings.original
    private(set) var appliedFilter: String = Strings.original
    
    @Published var isShowFiltes: Bool = false
    var tempOriginalImage: UIImage?

    @Published var showAlert: Bool = false
    @Published var showSettingsAlert: Bool = false
    
    // MARK: - Adjust state (bound to sliders = live preview values)
    @Published var isShowAdjust: Bool = false
    @Published var contrast: Double = 1.0
    @Published var brightness: Double = 0.0
    @Published var dark: Double = 0.0
    @Published var hueAngle: Double = 0.0
    @Published var saturation: Double = 1.0
    @Published var temp: Double = 6500.0
    @Published var vignette: Double = 0.0

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

    var adjustDetail: [PersonalDetail] = [PersonalDetail(id: 0, name: Strings.contrast, value: "ic_constrast"),
                                          PersonalDetail(id: 1, name: Strings.light, value: "ic_light"),
                                          PersonalDetail(id: 2, name: Strings.dark, value: "ic_dark"),
                                          PersonalDetail(id: 3, name: Strings.hue, value: "ic_hue"),
                                          PersonalDetail(id: 4, name: Strings.saturation, value: "ic_saturation"),
                                          PersonalDetail(id: 5, name: Strings.temp, value: "ic_temp"),
                                          PersonalDetail(id: 6, name: Strings.vignette, value: "ic_vignette")]

    let filters = [
        Strings.original, Strings.sepia, Strings.mono, Strings.nori, Strings.fade, Strings.chrome,
        Strings.vintage, Strings.dramatic, Strings.cool, Strings.warm, Strings.boost, Strings.vivid,
        Strings.vividWarm, Strings.vividCool, Strings.process, Strings.transfer, Strings.instant,
        Strings.tonal, Strings.bloom, Strings.gloom, Strings.sharpen, Strings.crystallize,
        Strings.pixelate, Strings.comic, Strings.edges, Strings.posterize, Strings.vignette
    ]

    // MARK: - Initial photo load

    /// Call this ONCE right after the user picks a photo from PhotosPicker.
    func setInitialImage(_ image: UIImage) {
        originalImage = image
        appliedFilter = Strings.original
        selectedFilter = Strings.original
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
        isShowAdjust = false
        pushLocalsFromCommitted()
        render()
    }

    func saveAdjust() {
        committedAdjust = currentAdjustValues()
        isShowAdjust = false
    }

    /// Called from slider onChange for live preview while dragging.
    func applyAdjustments() {
        render()
    }

    // MARK: - Crop
    func applyCrop(_ croppedImage: UIImage) {
        originalImage = croppedImage
        appliedFilter = Strings.original
        selectedFilter = Strings.original
        committedAdjust = AdjustValues()
        pushLocalsFromCommitted()
        selectedImage = croppedImage
    }

    // MARK: - Filter panel
    func openFilterPanel() {
        if !isShowFiltes {
            // Base = original + committed adjustments, WITHOUT any filter baked in,
            // so filters never stack on top of a previous filter.
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
        appliedFilter = Strings.original
        selectedFilter = Strings.original
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

    func saveImageUsingPhotos(image: UIImage) {

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
            DispatchQueue.main.async {
                switch newStatus {
                case .authorized, .limited:
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        if success {
                            print("Successfully saved to Photos library.")
                            
                            DispatchQueue.main.async {
                                self.showAlert = true
                            }
                        } else if let error = error {
                            print("Failed to save image: \(error.localizedDescription)")
                        }
                    }
                    
                case .denied, .restricted:
                    print("Permission denied")
                    self.showSettingsAlert = true
                    
                case .notDetermined:
                    print("Permission not determined yet")
                    self.showSettingsAlert = true
                    
                @unknown default:
                    self.showSettingsAlert = true
                }
            }
        }
    }
    
    func applyFilter(_ image: UIImage, filter: String) -> UIImage {
       guard let ciImage = CIImage(image: image) else { return image }

       let context = CIContext()
       var outputImage: CIImage?

       switch filter {
       case Strings.original:
           return image

       case Strings.sepia:
           let filter = CIFilter.sepiaTone()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           outputImage = filter.outputImage

       case Strings.mono:
           let filter = CIFilter.photoEffectMono()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.nori:
           let filter = CIFilter.photoEffectNoir()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.fade:
           let filter = CIFilter.photoEffectFade()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.chrome:
           let filter = CIFilter.photoEffectChrome()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.vintage:
           let filter = CIFilter.photoEffectTransfer()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.dramatic:
           let filter = CIFilter.photoEffectProcess()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.instant:
           let filter = CIFilter.photoEffectInstant()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.tonal:
           let filter = CIFilter.photoEffectTonal()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.cool:
           let filter = CIFilter.temperatureAndTint()
           filter.inputImage = ciImage
           filter.targetNeutral = CIVector(x: 6500, y: 0)
           outputImage = filter.outputImage

       case Strings.warm:
           let filter = CIFilter.temperatureAndTint()
           filter.inputImage = ciImage
           filter.targetNeutral = CIVector(x: 4500, y: 0)
           outputImage = filter.outputImage

       case Strings.boost:
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.3
           filter.contrast = 1.1
           filter.brightness = 0.05
           outputImage = filter.outputImage

       case Strings.vivid:
           let filter = CIFilter.colorControls()
           filter.inputImage = ciImage
           filter.saturation = 1.5
           filter.contrast = 1.2
           filter.brightness = 0
           outputImage = filter.outputImage

       case Strings.vividWarm:
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

       case Strings.vividCool:
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

       case Strings.process:
           let filter = CIFilter.photoEffectProcess()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.transfer:
           let filter = CIFilter.photoEffectTransfer()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.bloom:
           let filter = CIFilter.bloom()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           filter.radius = 10
           outputImage = filter.outputImage

       case Strings.gloom:
           let filter = CIFilter.gloom()
           filter.inputImage = ciImage
           filter.intensity = 0.8
           filter.radius = 10
           outputImage = filter.outputImage

       case Strings.sharpen:
           let filter = CIFilter.sharpenLuminance()
           filter.inputImage = ciImage
           filter.sharpness = 0.8
           outputImage = filter.outputImage

       case Strings.crystallize:
           let filter = CIFilter.crystallize()
           filter.inputImage = ciImage
           filter.radius = 15
           outputImage = filter.outputImage

       case Strings.pixelate:
           let filter = CIFilter.pixellate()
           filter.inputImage = ciImage
           filter.scale = 20
           outputImage = filter.outputImage

       case Strings.comic:
           let filter = CIFilter.comicEffect()
           filter.inputImage = ciImage
           outputImage = filter.outputImage

       case Strings.edges:
           let filter = CIFilter.edges()
           filter.inputImage = ciImage
           filter.intensity = 1.0
           outputImage = filter.outputImage

       case Strings.posterize:
           let filter = CIFilter.colorPosterize()
           filter.inputImage = ciImage
           filter.levels = 6
           outputImage = filter.outputImage

       case Strings.vignette:
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
