//
//  UIImage+Bitmap.swift
//  rampage
//
//  Created by David Chambers on 10/20/26.
//

import Foundation
import UIKit
import Engine

extension UIImage {
    convenience init?(bitmap: Bitmap) {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixel = MemoryLayout<Engine.Color>.size
        let bytesPerRow = bitmap.width * bytesPerPixel
        
        let data = bitmap.pixels.withUnsafeBytes { buffer in
            Data(buffer)
        }
        
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        
        guard let cgImage = CGImage(
            width: bitmap.width,
            height: bitmap.height,
            bitsPerComponent: 8,
            bitsPerPixel: bytesPerPixel * 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
}
