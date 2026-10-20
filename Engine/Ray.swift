//
//  Ray.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation

public struct Ray {
    public var origin, direction: Vector

    public init(origin: Vector, direction: Vector) {
        self.origin = origin
        self.direction = direction
    }
}
