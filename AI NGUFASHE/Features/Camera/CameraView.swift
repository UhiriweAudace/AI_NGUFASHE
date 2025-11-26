//
//  CameraView.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//
import SwiftUI

// MARK: - Color Palette Extension
extension Color {
    static let midnightNavy = Color(red: 10/255, green: 25/255, blue: 47/255) // Deepest background
    static let royalNavy = Color(red: 23/255, green: 42/255, blue: 69/255)    // Card background
    static let electricBlue = Color(red: 100/255, green: 255/255, blue: 218/255) // Accent (Cyan/Teal)
    static let softBlue = Color(red: 136/255, green: 146/255, blue: 176/255)  // Muted text
}

struct CameraView: View {
    @StateObject private var vm = CameraViewModel()
    @State private var showCamera = false
    @FocusState private var isPromptFocused: Bool
    
    // Animation states for the background blobs
    @State private var animateBlobs = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Animated Background
                ZStack {
                    Color.midnightNavy.ignoresSafeArea()
                    
                    // Moving Shapes
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        // Shape 1 (Top Left)
                        Circle()
                            .fill(Color.blue.opacity(0.4))
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: animateBlobs ? -50 : -150, y: animateBlobs ? -50 : -150)
                        
                        // Shape 2 (Bottom Right)
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 350, height: 350)
                            .blur(radius: 70)
                            .offset(
                                x: animateBlobs ? size.width - 200 : size.width - 100,
                                y: animateBlobs ? size.height - 200 : size.height - 100
                            )
                        
                        // Shape 3 (Center Moving)
                        Circle()
                            .fill(Color.electricBlue.opacity(0.15))
                            .frame(width: 200, height: 200)
                            .blur(radius: 50)
                            .position(x: size.width / 2, y: size.height / 2)
                            .offset(x: animateBlobs ? 80 : -80, y: animateBlobs ? -50 : 50)
                    }
                }
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 7)
                        .repeatForever(autoreverses: true)
                    ) {
                        animateBlobs.toggle()
                    }
                }

                // MARK: - Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - SECTION 1: SCANNED TEXT
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Label("SCANNED INPUT", systemImage: "doc.viewfinder")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .tracking(1) // Letter spacing
                                    .foregroundStyle(Color.electricBlue)
                                
                                Spacer()
                                
                                Button(action: { showCamera = true }) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color.midnightNavy)
                                        .padding(8)
                                        .background(Color.electricBlue)
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            
                            Divider()
                                .background(Color.white.opacity(0.1))

                            ZStack(alignment: .topLeading) {
                                if vm.extractedText.isEmpty {
                                    Text("Tap the camera icon to scan text...")
                                        .foregroundColor(Color.softBlue.opacity(0.5))
                                        .padding(.top, 8)
                                        .padding(.leading, 5)
                                        .font(.system(size: 16))
                                }
                                
                                TextEditor(text: $vm.extractedText)
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .frame(minHeight: 140)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .tint(Color.electricBlue)
                                    .font(.system(size: 16))
                            }
                            .padding()
                        }
                        .background(Color.royalNavy.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(LinearGradient(colors: [.white.opacity(0.2), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        .padding(.top, 10)

                        // MARK: - SECTION 2: AI RESULT
                        if !vm.apiResponse.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundStyle(Color.electricBlue)
                                    
                                    Text("INTELLIGENCE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .tracking(1)
                                        .foregroundStyle(Color.softBlue)
                                }
                                
                                // UPDATED: Parse JSON and Render Markdown
                                Text(.init(parseAIResponse(vm.apiResponse)))
                                    .lineSpacing(6)
                                    .foregroundStyle(.white)
                                    .textSelection(.enabled) // Allows user to copy text
                            }
                            .padding(24)
                            .background(Color.royalNavy.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.electricBlue.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 15, x: 0, y: 8)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("AI")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            
            // MARK: - BOTTOM INPUT BAR
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    TextField("", text: $vm.prompt, prompt: Text("Ask anything...").foregroundColor(Color.softBlue))
                        .padding(14)
                        .background(Color.royalNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .foregroundStyle(.white)
                        .focused($isPromptFocused)
                        .tint(Color.electricBlue)

                    Button(action: {
                        Task { await vm.sendToBackend() }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.midnightNavy)
                            .frame(width: 50, height: 50)
                            .background(Color.electricBlue)
                            .clipShape(Circle())
                            .shadow(color: Color.electricBlue.opacity(0.4), radius: 10, x: 0, y: 0)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.midnightNavy.opacity(0), Color.midnightNavy],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .padding(.bottom, -50)
                )
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $vm.selectedImage)
            }
            .onChange(of: vm.selectedImage) { _ in
                Task { await vm.processImage() }
            }
        }
    }
    
    // MARK: - Helper Function to Clean JSON
    func parseAIResponse(_ rawText: String) -> String {
        // 1. Try to convert string to Data
        guard let data = rawText.data(using: .utf8) else { return rawText }
        
        // 2. Try to decode into a dictionary
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let answer = json["answer"] as? String {
            return answer
        }
        
        // 3. Fallback: If it's not JSON, return original text
        return rawText
    }
}

#Preview {
    ContentView()
}

