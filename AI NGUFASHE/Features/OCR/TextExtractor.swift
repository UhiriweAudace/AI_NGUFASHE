//
//  TextExtractor.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import UIKit
import Vision

class TextExtractor {
    /// Extracts readable text from a UIImage using Vision OCR.
    /// Calls completion on a background thread; we do not assume main thread.
    static func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let request = VNRecognizeTextRequest { (req, err) in
            if let err = err {
                print("Vision error: \(err)")
                completion("")
                return
            }

            let observations = req.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { obs -> String? in
                // take the top candidate from each observation
                return obs.topCandidates(1).first?.string
            }
            let fullText = lines.joined(separator: "\n")
            completion(fullText)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-US"] // adjust or make dynamic if needed

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform Vision request: \(error)")
                completion("")
            }
        }
    }
}
