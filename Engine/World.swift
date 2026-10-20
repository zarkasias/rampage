//
//  World.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation



public struct World {
    public let map: Tilemap
    public var player: Player

    public init(map: Tilemap) {
        self.map = map

        var startingPlayer: Player?

        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let position = Vector(
                    x: Double(x) + 0.5,
                    y: Double(y) + 0.5
                )

                let thing = map.things[y * map.width + x]

                switch thing {
                case .nothing:
                    break
                case .player:
                    startingPlayer = Player(position: position)
                }
            }
        }

        guard let startingPlayer else {
            preconditionFailure("Map must contain a player")
        }

        self.player = startingPlayer
    }
}

public extension World {
    var size: Vector {
        return map.size
    }

   
    
    
    mutating func update(timeStep: Double, input: Input) {
        // Rotate player's facing direction
        player.direction = player.direction.rotated(by: input.rotation)

        // Move forwards or backwards
        player.velocity = player.direction * input.speed * player.speed
        player.position += player.velocity * timeStep

        // Resolve collisions with walls
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }


}


