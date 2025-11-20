//
//  TextExtractor.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//
import UIKit
import Vision

struct TextExtractor {

    static func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        let results = request.results ?? []
        let text = results.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")

        return text
    }
}
