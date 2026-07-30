//
//  ImageCropView.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 30/07/26.
//

import Foundation
import SwiftUI
import TOCropViewController

struct ImageCropperView: UIViewControllerRepresentable {
    let image: UIImage
    var cropShapeType: TOCropViewCroppingStyle = .default
    var onCropped: (UIImage) -> Void
    var onCancelled: () -> Void

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropVC = TOCropViewController(croppingStyle: cropShapeType, image: image)
        cropVC.delegate = context.coordinator
        // Optional customizations:
        cropVC.aspectRatioLockEnabled = false
        cropVC.resetAspectRatioEnabled = true
        cropVC.rotateButtonsHidden = false
        cropVC.doneButtonTitle = "Done"
        cropVC.cancelButtonTitle = "Cancel"
        return cropVC
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) {
        // no-op, nothing to update dynamically
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, TOCropViewControllerDelegate {
        let parent: ImageCropperView

        init(_ parent: ImageCropperView) {
            self.parent = parent
        }

        func cropViewController(
            _ cropViewController: TOCropViewController,
            didCropTo image: UIImage,
            with cropRect: CGRect,
            angle: Int
        ) {
            parent.onCropped(image)
            cropViewController.dismiss(animated: true)
        }

        func cropViewController(
            _ cropViewController: TOCropViewController,
            didFinishCancelled cancelled: Bool
        ) {
            parent.onCancelled()
            cropViewController.dismiss(animated: true)
        }
    }
}
