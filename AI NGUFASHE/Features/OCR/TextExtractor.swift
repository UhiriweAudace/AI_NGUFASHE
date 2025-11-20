//
//  TextExtractor.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import UIKit
import Vision

struct TextExtractor {
    static func extract(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage ?? image.ensureCGImage() else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let err = error {
                print("Vision text request error:", err.localizedDescription)
                completion("")
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            let combined = lines.joined(separator: "\n")
            completion(combined)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        // Leave recognitionLanguages empty to use system defaults, or set like ["en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition:", error)
                completion("")
            }
        }
    }
}
