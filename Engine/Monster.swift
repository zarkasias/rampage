//
//  Monster.swift
//  Engine
//
//  Created by David Chambers on 10/21/26.
//

import Foundation

public struct Monster: Actor {
    public let radius: Double = 0.45
    public var position: Vector
    
    public init(position: Vector) {
        self.position = position
    }
}
