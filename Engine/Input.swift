//
//  Input.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation


public struct Input {
    public var speed: Double
    public var rotation: Rotation

    public init(speed: Double, rotation: Rotation) {
        self.speed = speed
        self.rotation = rotation
    }
}

