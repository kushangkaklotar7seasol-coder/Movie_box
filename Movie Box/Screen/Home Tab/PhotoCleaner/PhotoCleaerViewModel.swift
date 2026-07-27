//
//  PhotoCleaerViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 27/07/26.
//

import Foundation
internal import Combine
import Photos
import CryptoKit
internal import UIKit

class PhotoCleaerViewModel: ObservableObject {
    @Published var duplicateGroups: [[PHAsset]] = []
    @Published var selectedAssetIds: Set<String> = []
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var hasPermission = false
    
    init() {
        self.requestPermission { granted in
            self.hasPermission = granted
            
            if granted {
                self.scanForDuplicates()
            }
        }
    }
    
    
    func toggleSelection(for asset: PHAsset) {
         if selectedAssetIds.contains(asset.localIdentifier) {
             selectedAssetIds.remove(asset.localIdentifier)
         } else {
             selectedAssetIds.insert(asset.localIdentifier)
         }
     }
     
     func isSelected(_ asset: PHAsset) -> Bool {
         selectedAssetIds.contains(asset.localIdentifier)
     }
     
     // Whole group select/deselect toggle
     func toggleSelectAll(for group: [PHAsset]) {
         let allSelected = isAllSelected(in: group)
         
         if allSelected {
             // Badha selected che → badha deselect karo
             group.forEach { selectedAssetIds.remove($0.localIdentifier) }
         } else {
             // Badha select karo
             group.forEach { selectedAssetIds.insert($0.localIdentifier) }
         }
     }
     
     func isAllSelected(in group: [PHAsset]) -> Bool {
         !group.isEmpty && group.allSatisfy { selectedAssetIds.contains($0.localIdentifier) }
     }
     
     var selectedCount: Int {
         selectedAssetIds.count
     }
     
    func requestPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    func scanForDuplicates() {
        isScanning = true
        duplicateGroups = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            
            var hashMap: [String: [PHAsset]] = [:]
            let total = assets.count
            var processed = 0
            
            assets.enumerateObjects { asset, _, _ in
                if let hash = self.generateHash(for: asset) {
                    hashMap[hash, default: []].append(asset)
                }
                
                processed += 1
                DispatchQueue.main.async {
                    self.progress = Double(processed) / Double(total)
                }
            }
            
            let groups = hashMap.values.filter { $0.count > 1 }
            
            DispatchQueue.main.async {
                self.duplicateGroups = Array(groups)
                self.isScanning = false
            }
        }
    }
    
    // Simple exact-match approach: thumbnail data ka hash
    private func generateHash(for asset: PHAsset) -> String? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        
        var resultHash: String?
        let targetSize = CGSize(width: 100, height: 100)
        
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
            if let image = image, let data = image.pngData() {
                let digest = SHA256.hash(data: data)
                resultHash = digest.compactMap { String(format: "%02x", $0) }.joined()
            }
        }
        
        return resultHash
    }
    
    func deleteAssets(completion: @escaping (Bool) -> Void) {
        var delatableAsset: [PHAsset] = []
        
        for i in self.duplicateGroups {
            for image in i {
                if self.isSelected(image) {
                    delatableAsset.append(image)
                }
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(delatableAsset as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    // Delete pachi local groups thi bhi remove karo (rescan na karvu pade etle)
    func removeDeletedAssetsFromGroups() {
        var updatedGroups: [[PHAsset]] = []
        
        for group in duplicateGroups {
            let remaining = group.filter { !selectedAssetIds.contains($0.localIdentifier) }
            if remaining.count > 1 {
                updatedGroups.append(remaining)
            }
        }
        
        self.duplicateGroups = []
        self.selectedAssetIds = []
        self.scanForDuplicates()
    }
    
}
