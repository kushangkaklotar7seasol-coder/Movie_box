//
//  PhotoEditScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//
import SwiftUI
import _PhotosUI_SwiftUI

struct PhotoEditScreen: View {
    @StateObject var viewModel = PhotoEditViewModel()

    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: "Photo Editor")
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    ZStack {
                        if viewModel.isPhtoAvailable {
                            if let image = viewModel.selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                            }
                        } else {
                            PhotosPicker(
                                selection: $viewModel.selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Text("Select a photo for edit")
                                    .padding()
                                    .foregroundColor(.blackColour)
                                    .background(.blackColour.opacity(0.2))
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(viewModel.isPhtoAvailable ? .clear : .grayColour)
                    .cornerRadius(24)
                    .padding(.horizontal, 16)

                    if viewModel.isPhtoAvailable {
                        ZStack {
                            HStack {
                                PhotoEditDesign.btn(image: "ic_crop", name: "Crop", isSelected: false)
                                    .onTapGesture {
                                        viewModel.isShowCropper = true
                                    }
                                PhotoEditDesign.btn(image: "ic_filter", name: "Filter", isSelected: viewModel.isShowFiltes)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.openFilterPanel()
                                        }
                                    }
                                
                                PhotoEditDesign.btn(image: "ic_adjust", name: "Adjust", isSelected: false)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.openAdjustPanel()
                                        }
                                    }
                            }
                            .padding(.bottom, 30)
                            
                            if viewModel.isShowFiltes {
                                PhotoEditDesign.FilterBottomview(viewModel: viewModel)
                                    .background(
                                        Color.backgroundColour
                                            .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                                            .ignoresSafeArea(edges: .bottom)
                                    )
                            }
                            
                            if viewModel.isShowAdjust {
                                PhotoEditDesign.AdjustBottomView(viewModel: viewModel)
                                    .background(
                                        Color.backgroundColour
                                            .clipShape(.rect(topLeadingRadius: 20, topTrailingRadius: 20))
                                            .ignoresSafeArea(edges: .bottom)
                                    )
                            }
                        }
                        
                    }
                }
            }
        }
        .defaultPage()
        .onChange(of: viewModel.selectedItem) { _, newItem in
            Task {
                if let newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.setInitialImage(image)
                    } else {
                        print("Failed to process asset data.")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isShowCropper) {
            if let originalImage = viewModel.selectedImage {
                ImageCropperView(
                    image: originalImage,
                    onCropped: { cropped in
                        viewModel.selectedImage = cropped
                        viewModel.isShowCropper = false
                    },
                    onCancelled: {
                        viewModel.isShowCropper = false
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    PhotoEditScreen()
}

class PhotoEditDesign {

    struct btn: View {
        var image: String
        var name: String
        let isSelected: Bool

        var body: some View {
            VStack(spacing: 0) {
                Image(image)
                    .resizable()
                    .frame(width: 30, height: 30, alignment: .center)

                Text(name)
                    .foregroundColor(.grayColour)
            }
            .frame(width: (screenWidth-71)/3, height: 80, alignment: .center)
            .background(.backgroundColour)
            .cornerRadius(10)
//            .overlay {
//                RoundedRectangle(cornerRadius: 10)
//                    .strokeBorder(LinearGradient(colors: [isSelected ? .cyanColour : .whiteColour.opacity(0.2),
//                                                          isSelected ? .greenColour : .whiteColour.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: isSelected ? 3 : 0)
//            }
        }
    }

    struct FilterBottomview: View {
        @StateObject var viewModel: PhotoEditViewModel

        var body: some View {
            VStack {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.cancelFilter()
                        }
                    } label: {
                        Image("ic_cancel_clear")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }

                    Spacer()

                    Text("Filter")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.grayColour)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.saveFilter()
                        }
                    } label: {
                        Image("ic_right_green")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.filters, id: \.self) { filter in
                            if let image = viewModel.tempOriginalImage {
                                FilterThumbnailView(image: image, filterName: filter, isSelected: viewModel.selectedFilter == filter)
                                    .onTapGesture {
                                        viewModel.selectedFilter = filter
                                        viewModel.selectedImage = viewModel.applyFilter(image, filter: filter)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 5)
                }
            }
            .padding(.bottom, 50)
        }
    }

    struct AdjustBottomView: View {
        @StateObject var viewModel: PhotoEditViewModel
        @State var selectedAdjustId: Int = 0

        var body: some View {
            VStack {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.cancelAdjust()
                        }
                    } label: {
                        Image("ic_cancel_clear")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }

                    Spacer()

                    Text("Adjust")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.grayColour)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.saveAdjust()
                        }
                    } label: {
                        Image("ic_right_green")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                VStack {
                    if selectedAdjustId == 0 {
                        CustomGradientSlider(
                            value: $viewModel.contrast,
                            bounds: 0.0...2.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.contrast) { oldValue, newValue in
                            viewModel.applyAdjustments()
                        }
                        Text("\(viewModel.contrast)")
                    } else if selectedAdjustId == 1 {
                        CustomGradientSlider(
                            value: $viewModel.brightness,
                            bounds: -0.5...0.5,
                            step: 0.1
                        )
                        .onChange(of: viewModel.brightness) { oldValue, newValue in
                            viewModel.applyAdjustments()
                        }
                        Text("\(viewModel.brightness)")
                    } else if selectedAdjustId == 2 {
                        CustomGradientSlider(
                            value: $viewModel.dark,
                            bounds: -1.0...1.0,
                            step: 0.05
                        )
                        .onChange(of: viewModel.dark) { _, _ in
                            viewModel.applyAdjustments()
                        }
                        Text(String(format: "%.2f", viewModel.dark))
                    } else if selectedAdjustId == 3 {
                        CustomGradientSlider(
                            value: $viewModel.hueAngle,
                            bounds: -3.14...3.14,
                            step: 0.1
                        )
                        .onChange(of: viewModel.hueAngle) { _, _ in
                            viewModel.applyAdjustments()
                        }
                        Text(String(format: "%.2f", viewModel.hueAngle))
                    } else if selectedAdjustId == 4 {
                        CustomGradientSlider(
                            value: $viewModel.saturation,
                            bounds: -0.0...2.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.saturation) { _, _ in
                            viewModel.applyAdjustments()
                        }
                        Text(String(format: "%.2f", viewModel.saturation))
                    } else if selectedAdjustId == 5 {
                        CustomGradientSlider(
                            value: $viewModel.temp,
                            bounds: 3000.0...10000.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.temp) { _, _ in
                            viewModel.applyAdjustments()
                        }
                        Text(String(format: "%.2f", viewModel.temp))
                    } else if selectedAdjustId == 6 {
                        CustomGradientSlider(
                            value: $viewModel.vignette,
                            bounds: 0.0...2.0,
                            step: 0.1
                        )
                        .onChange(of: viewModel.vignette) { _, _ in
                            viewModel.applyAdjustments()
                        }
                        Text(String(format: "%.2f", viewModel.vignette))
                    }
                }
                .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.adjustDetail, id: \.id) { item in
                            let isSelected = item.id == selectedAdjustId
                            VStack {
                                ZStack {
                                    Image(item.value)
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFill()
                                        .foregroundColor(isSelected ? .whiteColour : . gray)
                                        .frame(width: 30, height: 30, alignment: .center)
                                }
                                .frame(width: 60, height: 60, alignment: .center)
                                .background(.blackColour)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder( LinearGradient(colors: [isSelected ? .cyanColour : .grayColour,
                                                                               isSelected ? .greenColour : .grayColour],
                                                                      startPoint: .top,
                                                                      endPoint: .bottom) , lineWidth: 1)
                                )

                                Text(item.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(isSelected ? .whiteColour : . gray)
                            }
                            .onTapGesture {
                                selectedAdjustId = item.id
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 50)
        }
    }
}

struct FilterThumbnailView: View {
    let image: UIImage
    let filterName: String
    let isSelected: Bool

    @State private var thumbnailImage: UIImage?

    // Shared across every thumbnail instance so we don't spin up a brand new
    // (expensive) Metal/CIContext for each of the 27 filters at once.
    private static let sharedContext = CIContext()
    // Serial queue -> thumbnails render one at a time instead of ~27 filters
    // hitting the GPU/CPU concurrently, which is what was crashing the app.
    private static let thumbnailQueue = DispatchQueue(label: "com.app.filterThumbnailQueue")

    var body: some View {
        VStack(spacing: 8) {
            // Thumbnail Image with white border when selected
            ZStack {
                if let thumbnail = thumbnailImage {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    LinearGradient(colors: [.cyanColour, .greenColour], startPoint: .top, endPoint: .bottom), lineWidth: isSelected ? 3 : 0
                                )
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .cornerRadius(8)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
            }
            
            // Filter Name
            Text(filterName)
                .foregroundColor(isSelected ? .white : .gray)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .frame(width: 70)
        }
        .onAppear {
            generateThumbnail()
        }
    }

    private func generateThumbnail() {
        Self.thumbnailQueue.async {
            let smallImage = resize(image, to: CGSize(width: 140, height: 140))
            let filteredImage = applyFilter(smallImage, filter: filterName)
            DispatchQueue.main.async {
                self.thumbnailImage = filteredImage
            }
        }
    }

    private func resize(_ image: UIImage, to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func applyFilter(_ image: UIImage, filter: String) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let context = Self.sharedContext
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
