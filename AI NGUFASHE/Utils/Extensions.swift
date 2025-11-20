//
//  Extensions.swift
//  AI NGUFASHE
//
//  Created by Audace Uhiriwe on 11/18/25.
//

import UIKit
import CoreImage

extension UIImage {
    /// Ensure there is a cgImage (render if not present)
    func ensureCGImage() -> CGImage? {
        if let cg = self.cgImage { return cg }
        guard let ci = CIImage(image: self) else { return nil }
        let ctx = CIContext()
        return ctx.createCGImage(ci, from: ci.extent)
    }
}
