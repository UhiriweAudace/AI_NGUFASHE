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

      var body: some View {
          NavigationStack {
              VStack(spacing: 0) {

                  ScrollView {
                      VStack(spacing: 24) {

                          // MARK: - OCR TEXT CARD
                          VStack(alignment: .leading, spacing: 12) {

                              Text("""
                                  Here is some text that has been automatically extracted 
                                  from an image using OCR technology. 
                                  You can edit this text before sending it to the AI.
                                  
                                """)
                                  .font(.body)
                                  .foregroundColor(.primary)

                              TextEditor(text: $vm.extractedText)
                                  .frame(minHeight: 140)
                                  .padding(12)
                                  .background(Color(.systemGray6))
                                  .cornerRadius(10)

                              HStack {
                                  Spacer()
                                  Button(action: { showCamera = true }) {
                                      HStack(spacing: 6) {
                                          Image(systemName: "camera.fill")
                                          Text("Re-capture")
                                      }
                                      .font(.subheadline)
                                  }
                              }
                          }
                          .padding()
                          .background(Color.white)
                          .cornerRadius(14)
                          .shadow(color: .black.opacity(0.05), radius: 6, y: 2)

                          // MARK: - AI RESULT
                          if !vm.apiResponse.isEmpty {
                              VStack(alignment: .leading, spacing: 12) {

                                  Text("AI Result")
                                      .font(.headline)
                                      .foregroundColor(.gray)

                                  Text(vm.apiResponse)
                                      .font(.body)
                                      .frame(maxWidth: .infinity, alignment: .leading)
                              }
                              .padding()
                              .background(Color.white)
                              .cornerRadius(14)
                              .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
                          }
                      }
                      .padding(.horizontal)
                      .padding(.top, 20)
                  }

                  // MARK: - BOTTOM PROMPT INPUT
                  HStack(spacing: 12) {
                      TextField("Ask AI anything...", text: $vm.prompt)
                          .padding(14)
                          .background(Color(.systemGray6))
                          .cornerRadius(20)
                          .focused($isPromptFocused)

                      Button(action: {
                          Task { await vm.sendToBackend() }
                      }) {
                          Image(systemName: "arrow.up.circle.fill")
                              .font(.system(size: 36))
                      }
                  }
                  .padding()
                  .background(Color(.systemBackground))
              }
              .navigationTitle("AI Assistant")
              .sheet(isPresented: $showCamera) {
                  ImagePicker(image: $vm.selectedImage)
              }
              .onChange(of: vm.selectedImage) { _ in
                  Task { await vm.processImage() }
              }
          }
      }
}
