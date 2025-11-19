//
//  CameraController.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import UIKit
import AVFoundation

class CameraController: UIViewController {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!

    // The delegate instance is supplied by the SwiftUI wrapper coordinator
    weak var photoCaptureDelegate: AVCapturePhotoCaptureDelegate?
    var onPhotoCaptured: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupSession()
        setupPreview()
        session.startRunning()

        // listen for external "capture" requests (from a UI button)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCaptureNotification), name: .capturePhoto, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // add camera input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Couldn't create camera input")
            return
        }
        session.addInput(input)

        // add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()
    }

    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.connection?.videoOrientation = .portrait
        view.layer.addSublayer(previewLayer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    @objc func handleCaptureNotification() {
        capturePhoto()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        // prefer JPEG
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        photoOutput.capturePhoto(with: settings, delegate: photoCaptureDelegate ?? self)
    }
}

// fallback if someone forgets delegate (should not happen)
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            onPhotoCaptured?(image)
        }
    }
}
