//
//  CameraView.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraController

    var onPhotoCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraController {
        let controller = CameraController()
        controller.photoCaptureDelegate = context.coordinator
        controller.onPhotoCaptured = onPhotoCaptured
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput,
                         didFinishProcessingPhoto photo: AVCapturePhoto,
                         error: Error?) {

            if let error = error {
                print("Photo capture error: \(error)")
                return
            }

            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                print("Unable to get image data")
                return
            }

            parent.onPhotoCaptured(image)
        }
    }
}
