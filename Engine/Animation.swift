//
//  Animation.swift
//  Engine
//
//  Created by David Chambers on 10/21/26.
//

import Foundation

public struct Animation {
    public let frames: [Texture]
    public let duration: Double
    public var time: Double = 0

    public init(frames: [Texture], duration: Double) {
        self.frames = frames
        self.duration = duration
    }
}

public extension Animation {
    var texture: Texture {
        guard duration > 0 else {
            return frames[0]
        }

        let t = time.truncatingRemainder(
            dividingBy: duration
        ) / duration

        let frameIndex = Int(Double(frames.count) * t)
        return frames[frameIndex]
    }
}
