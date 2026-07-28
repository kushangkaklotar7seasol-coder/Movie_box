//
//  PhotoCleanerScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import SwiftUI
import Photos

struct PhotoCleanerScreen: View {
    @StateObject var viewModel = PhotoCleaerViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.photoCleaner)
                    .padding(.horizontal, 16)
                
                if !viewModel.duplicateGroups.isEmpty {
                    let totalDubPhotos = viewModel.duplicateGroups.reduce(0) { $0 + $1.count }
                    
                    Text("\(totalDubPhotos - viewModel.duplicateGroups.count) \(Strings.dublicatePhotoFound)")
                        .padding()
                        .font(.system(size: 18, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.backgroundColour)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.whiteColour.opacity(0.1))
                        )
                        .padding(.horizontal, 16)
//                }
                
                ScrollView(showsIndicators: false) {
//                    if !viewModel.duplicateGroups.isEmpty {
                        VStack {
                            ForEach(viewModel.duplicateGroups.indices, id: \.self) { groupIndex in
                                let group = viewModel.duplicateGroups[groupIndex]
                                let isSelected = viewModel.isAllSelected(in: group)
                                
                                HStack {
                                    Text("\(Strings.group) \(groupIndex + 1)")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Spacer()
                                    
                                    Button {
                                        viewModel.toggleSelectAll(for: group)
                                    } label: {
                                        Image(isSelected ? "ic_check" : "ic_uncheck")
                                            .resizable()
                                            .frame(width: 20, height: 20, alignment: .center)
                                        
                                        Text("Select All")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.grayColour)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 10)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(viewModel.duplicateGroups[groupIndex], id: \.localIdentifier) { asset in
                                            AssetThumbnail(asset: asset, selectedImage: viewModel.isSelected(asset) ? "ic_check" : "ic_uncheck")
                                                .onTapGesture {
                                                    viewModel.toggleSelection(for: asset)
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                } else {
                    Spacer()
                    
                    Text(Strings.noDublicate)
                        .font(.system(size: 21, weight: .semibold))
                    
                    Text(Strings.noDublicateInfo)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.grayColour)
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            VStack {
                if viewModel.isScanning {
                    ProgressView(value: viewModel.progress)
                        .padding()
                    Text("\(Strings.scaning) \(Int(viewModel.progress * 100))%")
                    
                } else if !viewModel.hasPermission {
                    
                    Text(Strings.permissionNote)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                
                if !viewModel.selectedAssetIds.isEmpty {
                    VStack {
                        Spacer()
                        
                        Button {
                            viewModel.deleteAssets(completion: {_ in 
                                viewModel.removeDeletedAssetsFromGroups()
                            })
                        } label: {
                            Text(Strings.deleteMedia)
                                .padding()
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [.skyBlue, .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    PhotoCleanerScreen()
}

struct AssetThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage?
    var selectedImage: String = ""
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 150, height: 150)
            }
            
            VStack {
                HStack {
                    
                    Spacer()
                    
                    Image(selectedImage)
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                }
                
                Spacer()
                
                HStack {
                    let size = self.getFileSize(for: asset)
                    Text(size)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.whiteColour)
                    
                    Spacer()
                }
            }
            .padding(5)
            
        }
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: options) { result, _ in
            self.image = result
        }
    }
    
    func getFileSize(for asset: PHAsset) -> String {
        let resources = PHAssetResource.assetResources(for: asset)
        
        guard let resource = resources.first,
              let sizeValue = resource.value(forKey: "fileSize") as? Int64 else {
            print("No resource found")
            return ""
        }
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        
        let sizeString = formatter.string(fromByteCount: sizeValue)
        return sizeString
    }
}
