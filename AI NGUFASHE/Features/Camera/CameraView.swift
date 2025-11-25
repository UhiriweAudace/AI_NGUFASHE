//
//  CameraView.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    @State private var showCamera = false
    @FocusState private var isPromptFocused: Bool

    // A subtle gradient for the "AI" feel
    let aiGradient = LinearGradient(
        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - SECTION 1: SCANNED CONTENT
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Label("Scanned Text", systemImage: "doc.text.viewfinder")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                
                                // Re-capture Button (Pill Style)
                                Button(action: { showCamera = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "camera")
                                        Text("Retake")
                                    }
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                                }
                            }
                            .padding()

                            Divider()

                            // Custom Editor Look
                            ZStack(alignment: .topLeading) {
                                if vm.extractedText.isEmpty {
                                    Text("Text detected from the camera will appear here...")
                                        .foregroundColor(.gray)
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                }
                                
                                TextEditor(text: $vm.extractedText)
                                    .font(.system(.body, design: .rounded))
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden) // Removes default gray background
                                    .background(Color.clear)
                            }
                            .padding()
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.top)

                        // MARK: - SECTION 2: AI RESULT
                        if !vm.apiResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .symbolRenderingMode(.multicolor)
                                    Text("AI Insight")
                                        .font(.system(.body, design:.serif))
                                }
                                .padding(.bottom, 4)

                                Text(vm.apiResponse)
                                    .font(.system(.body, design:.rounded)) // Serif font for "reading" feel
                                    .lineSpacing(4)
                                    .foregroundStyle(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(20)
                            .background(aiGradient)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.05), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        
                        // Spacer to ensure content isn't hidden behind the bottom bar
                        Color.clear.frame(height: 80)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("AI")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - BOTTOM FLOATING INPUT
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    TextField("Ask a follow-up question...", text: $vm.prompt)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(uiColor: .tertiarySystemBackground))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .focused($isPromptFocused)

                    Button(action: {
                        Task { await vm.sendToBackend() }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(vm.prompt.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                    }
                    .disabled(vm.prompt.isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial) // Glassmorphism effect
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $vm.selectedImage)
            }
            .onChange(of: vm.selectedImage) { _ in
                Task { await vm.processImage() }
            }
        }
    }
}

