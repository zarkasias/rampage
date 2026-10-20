//
//  Rect.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation


public struct Rect {
    public var min, max: Vector

    public init(min: Vector, max: Vector) {
        self.min = min
        self.max = max
    }
}
