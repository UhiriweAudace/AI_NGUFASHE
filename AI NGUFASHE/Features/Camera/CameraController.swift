//
//  CameraController.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import AVFoundation
import UIKit

final class CameraController: NSObject {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var photoOutput = AVCapturePhotoOutput()

    // keep delegate strong while capture is in progress
    private var currentPhotoDelegate: AVCapturePhotoCaptureDelegate?

    var onPhotoCaptured: ((UIImage) -> Void)?

    override init() {
        super.init()
        configureSession()
    }

    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // camera device
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                print("Camera input unavailable")
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)

            // photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func getSession() -> AVCaptureSession {
        return session
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true

        let delegate = PhotoCaptureDelegate { [weak self] data in
            guard let d = data, let image = UIImage(data: d) else {
                return
            }
            DispatchQueue.main.async {
                self?.onPhotoCaptured?(image)
            }
            // release delegate after capture finished
            self?.currentPhotoDelegate = nil
        }

        // keep a strong reference to the delegate so it lives until callback
        self.currentPhotoDelegate = delegate

        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
}

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Data?) -> Void

    init(completion: @escaping (Data?) -> Void) {
        self.completion = completion
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let err = error {
            print("Photo capture error: \(err)")
            completion(nil)
            return
        }
        completion(photo.fileDataRepresentation())
    }
}
