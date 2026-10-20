//
//  Player.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation



public struct Player {
    public var position: Vector
    public var velocity: Vector
    public let radius: Double = 0.5

    public init(position: Vector) {
        self.position = position
        self.velocity = Vector(x: 0, y: 0)
    }
}


public extension Player {
    var rect: Rect {
        let halfSize = Vector(x: radius, y: radius)

        return Rect(
            min: position - halfSize,
            max: position + halfSize
        )
    }
}



