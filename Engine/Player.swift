//
//  Player.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation



public struct Player: Actor {
    public var position: Vector
    public var velocity: Vector
    public var direction: Vector
    
    public let speed: Double = 3
    public let turningSpeed: Double = .pi
    public let radius: Double = 0.25

    public init(position: Vector) {
        self.position = position
        self.direction = Vector(x: 1, y: 0)
        self.velocity = Vector(x: 0, y: 0)
    }
}


