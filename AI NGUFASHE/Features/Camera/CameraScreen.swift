//
//  CameraScreen.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import SwiftUI

struct CameraScreen: View {
    var onCapture: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            CameraView { image in
                // pass captured image up
                onCapture(image)
                presentationMode.wrappedValue.dismiss()
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { NotificationCenter.default.post(name: .capturePhoto, object: nil) }) {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 76, height: 76)
                            .overlay(Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2))
                    }
                    .padding(.bottom, 36)
                    Spacer()
                }
            }
        }
    }
}
