//
//  Bitmap.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation

public struct Bitmap {
    public private(set) var pixels: [Color]
    public let width: Int
    
    public init(width: Int, pixels: [Color]) {
        self.width = width
        self.pixels = pixels
        
    }
}

public extension Bitmap {
    var height: Int {
        return pixels.count / width
    }
    
    subscript(x: Int, y: Int) -> Color {
        get {
            return pixels[y * width + x]
        }
        set {
            guard x >= 0, y >= 0, x < width, y < height else {
                return
            }

            pixels[y * width + x] = newValue
        }
    }
    
    
    mutating func fill(rect: Rect, color: Color) {
        for y in Int(rect.min.y) ..< Int(rect.max.y) {
            for x in Int(rect.min.x) ..< Int(rect.max.x) {
                self[x, y] = color
            }
        }
    }

    
    init(width: Int, height: Int, color: Color) {
        self.pixels = Array(repeating:color, count: width * height)
        self.width = width
    }
}
