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
    public var monsters: [Monster]

    public init(map: Tilemap) {
        self.map = map
        self.monsters = []

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
                case .monster:
                    self.monsters.append(
                        Monster(position: position)
                    )
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
        
        
        
        
        // Update monsters
     
        // Update monsters
        for i in monsters.indices {
            var monster = monsters[i]

            monster.update(in: self)

            // Move the monster based on velocity and elapsed time
            monster.position += monster.velocity * timeStep

            monsters[i] = monster
        }


        
        
        // Handle player-monster collisions
        
        for i in monsters.indices {
            var monster = monsters[i]

            // Player-to-monster collision
            if let intersection = player.intersection(with: monster) {
                player.position -= intersection / 2
                monster.position += intersection / 2
            }

            // Monster-to-monster collisions
            for j in (i + 1)..<monsters.count {
                if let intersection = monster.intersection(with: monsters[j]) {
                    monster.position -= intersection / 2
                    monsters[j].position += intersection / 2
                }
            }

            // Monster-to-wall collisions
            while let intersection = monster.intersection(with: map) {
                monster.position -= intersection
            }

            monsters[i] = monster
        }

        // Player-to-wall collisions (always last)
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }




        // Resolve collisions with walls
        while let intersection = player.intersection(with: map) {
            player.position -= intersection
        }
    }


}


public extension World {
    var sprites: [Billboard] {
        let spritePlane = player.direction.orthogonal

        return monsters.map { monster in
            Billboard(
                start: monster.position - spritePlane / 2,
                direction: spritePlane,
                length: 1
            )
        }
    }
}



