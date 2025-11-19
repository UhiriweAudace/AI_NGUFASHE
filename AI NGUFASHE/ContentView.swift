//
//  ContentView.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var extractedText: String = ""
    @State private var prompt: String = "Summarize the following text in 3 bullet points:"
    @State private var aiResult: String = ""
    @State private var loading: Bool = false
    @State private var statusMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    Button(action: { showCamera = true }) {
                        Label("Open Camera", systemImage: "camera")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {
                        // Clear everything
                        capturedImage = nil
                        extractedText = ""
                        aiResult = ""
                        statusMessage = ""
                    }) {
                        Text("Clear")
                    }
                }
                .padding(.horizontal)

                if let img = capturedImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                } else {
                    Rectangle()
                        .fill(Color(UIColor.systemGray6))
                        .frame(height: 220)
                        .overlay(Text("No image captured").foregroundColor(.secondary))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }

                Group {
                    Text("Extracted Text")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    TextEditor(text: $extractedText)
                        .frame(minHeight: 130, maxHeight: 180)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        .padding(.horizontal)
                }

                Group {
                    Text("Prompt")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    TextEditor(text: $prompt)
                        .frame(minHeight: 80, maxHeight: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        .padding(.horizontal)
                }

                HStack(spacing: 12) {
                    Button(action: sendToAI) {
                        if loading {
                            ProgressView()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            Text("Send to AI")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(loading || extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button(action: {
                        if let img = capturedImage {
                            // Retry OCR on the same image
                            statusMessage = "Re-extracting..."
                            TextExtractor.extractText(from: img) { txt in
                                DispatchQueue.main.async {
                                    self.extractedText = txt
                                    self.statusMessage = "Extracted \(txt.count) chars"
                                }
                            }
                        }
                    }) {
                        Text("Re-OCR")
                            .frame(width: 92)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(8)
                    }
                    .disabled(capturedImage == nil)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 6) {
                    Text("AI Result")
                        .font(.headline)
                    ScrollView {
                        Text(aiResult.isEmpty ? "(no result yet)" : aiResult)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(minHeight: 100, maxHeight: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                }
                .padding(.horizontal)

                if !statusMessage.isEmpty {
                    Text(statusMessage).foregroundColor(.secondary).padding(.horizontal)
                }

                Spacer()
            }
//            .navigationTitle("AI Camera OCR")
            .sheet(isPresented: $showCamera) {
                CameraScreen { image in
                    self.capturedImage = image
                    self.statusMessage = "Running OCR..."
                    TextExtractor.extractText(from: image) { text in
                        DispatchQueue.main.async {
                            self.extractedText = text
                            self.statusMessage = "Extracted \(text.count) chars"
                        }
                    }
                }
            }
        }
    }

    private func sendToAI() {
        let trimmed = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = "No text to send"
            return
        }

        loading = true
        statusMessage = "Sending to AI..."
        aiResult = ""

        AIService.askAI(text: trimmed, prompt: prompt) { result in
            DispatchQueue.main.async {
                self.loading = false
                switch result {
                case .success(let answer):
                    self.aiResult = answer
                    self.statusMessage = "Received response"
                case .failure(let err):
                    self.aiResult = "Error: \(err.localizedDescription)"
                    self.statusMessage = "Error"
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
