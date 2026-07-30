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
    @Published var isPhtoAvailable: Bool = true
    @Published var selectedItem: PhotosPickerItem? = nil
    @Published var originalImage: UIImage? = UIImage(named: "edit")
//    @Published var selectedImage: UIImage? = nil
    @Published var selectedImage: UIImage? = UIImage(named: "edit")
    @Published var isShowCropper: Bool = false
    
    
    @Published var selectedFilter: String = "Original"
    @Published var isShowFiltes: Bool = false
    let filters = [
        "Original", "Sepia", "Mono", "Noir", "Fade", "Chrome",
        "Vintage", "Dramatic", "Cool", "Warm", "Boost", "Vivid",
        "Vivid Warm", "Vivid Cool", "Process", "Transfer", "Instant",
        "Tonal", "Bloom", "Gloom", "Sharpen", "Crystallize",
        "Pixelate", "Comic", "Edges", "Posterize", "Vignette"
    ]
    
    func applyFilter(_ image: UIImage, filter: String) -> UIImage {
       guard let ciImage = CIImage(image: image) else { return image }
       
       let context = CIContext()
       var outputImage: CIImage?
       
       switch filter {
       // Basic Filters
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
           
       // Photo Effect Filters
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
           
       // Color Adjustment Filters
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
           if var output = outputImage {
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
           if var output = outputImage {
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
           
       // Stylize Filters
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


