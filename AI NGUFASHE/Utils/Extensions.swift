//
//  Extensions.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import UIKit

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

// UIImage convenience to ensure cgImage (if you need elsewhere)
extension UIImage {
    func ensureCGImage() -> CGImage? {
        if let cg = self.cgImage { return cg }
        // render into cg context
        let renderer = UIGraphicsImageRenderer(size: self.size)
        let img = renderer.image { _ in self.draw(at: .zero) }
        return img.cgImage
    }
}
