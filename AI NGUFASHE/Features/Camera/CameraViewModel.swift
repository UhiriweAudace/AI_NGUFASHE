//
//  CameraViewModel.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/20/25.
//

import SwiftUI
import UIKit
import Combine

class CameraViewModel: ObservableObject {

    @Published var selectedImage: UIImage?
    @Published var extractedText: String = ""
    @Published var prompt: String = ""
    @Published var apiResponse: String = ""
    @Published var isLoading: Bool = false

    // MARK: - OCR
    func processImage() async {
        guard let image = selectedImage else { return }

        isLoading = true
        do {
            extractedText = try await TextExtractor.extractText(from: image)
        } catch {
            extractedText = "Error extracting text."
        }
        isLoading = false
    }

    // MARK: - API
    func sendToBackend() async {
        guard !extractedText.isEmpty, !prompt.isEmpty else { return }

        isLoading = true
        do {
            let response = try await AIService.shared.sendToAPI(text: extractedText, prompt: prompt)
            apiResponse = response
        } catch {
            apiResponse = "Failed to send request."
        }
        isLoading = false
    }
}
