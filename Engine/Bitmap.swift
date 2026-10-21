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
    
    
    subscript(normalized x: Double, _ y: Double) -> Color {
        let textureX = min(
            width - 1,
            max(0, Int(x * Double(width)))
        )

        let textureY = min(
            height - 1,
            max(0, Int(y * Double(height)))
        )

        return self[textureX, textureY]
    }

    
    
    mutating func fill(rect: Rect, color: Color) {
        for y in Int(rect.min.y) ..< Int(rect.max.y) {
            for x in Int(rect.min.x) ..< Int(rect.max.x) {
                self[x, y] = color
            }
        }
    }
    
    
    mutating func drawLine(from: Vector, to: Vector, color: Color) {
        let difference = to - from
        let stepCount: Int
        let step: Vector

        if abs(difference.x) > abs(difference.y) {
            stepCount = Int(abs(difference.x).rounded(.up))

            let sign = difference.x > 0 ? 1.0 : -1.0

            step = Vector(
                x: 1,
                y: difference.y / difference.x
            ) * sign
        } else {
            stepCount = Int(abs(difference.y).rounded(.up))

            let sign = difference.y > 0 ? 1.0 : -1.0

            step = Vector(
                x: difference.x / difference.y,
                y: 1
            ) * sign
        }

        var point = from

        for _ in 0 ..< stepCount {
            self[Int(point.x), Int(point.y)] = color
            point += step
        }
    }
    
    
    mutating func drawColumn(
        _ sourceX: Int,
        of source: Bitmap,
        at point: Vector,
        height: Double
    ) {
        guard height > 0 else { return }

        let start = Int(point.y)
        let end = Int((point.y + height).rounded(.up))
        let stepY = Double(source.height) / height

        for y in max(0, start) ..< min(self.height, end) {
            let sourceY = max(0, Double(y) - point.y) * stepY

            let textureY = min(
                source.height - 1,
                Int(sourceY)
            )

            let sourceColor = source[sourceX, textureY]

                    blendPixel(
                        at: Int(point.x),
                        y,
                        with: sourceColor
                    )
        }
    }


    
    mutating func blendPixel(
        at x: Int,
        _ y: Int,
        with newColor: Color
    ) {
        // Fully transparent pixels leave the background unchanged
        if newColor.a == 0 {
            return
        }

        // Fully opaque pixels replace the background
        if newColor.a == 255 {
            self[x, y] = newColor
            return
        }

        let oldColor = self[x, y]

        let inverseAlpha =
            1.0 - Double(newColor.a) / 255.0

        // Images use premultiplied alpha
        self[x, y] = Color(
            r: UInt8(min(
                255,
                Double(oldColor.r) * inverseAlpha +
                    Double(newColor.r)
            )),
            g: UInt8(min(
                255,
                Double(oldColor.g) * inverseAlpha +
                    Double(newColor.g)
            )),
            b: UInt8(min(
                255,
                Double(oldColor.b) * inverseAlpha +
                    Double(newColor.b)
            ))
        )
    }


    
    init(width: Int, height: Int, color: Color) {
        self.pixels = Array(repeating:color, count: width * height)
        self.width = width
    }
}
