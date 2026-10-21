//
//  Monster.swift
//  Engine
//
//  Created by David Chambers on 10/21/26.
//

import Foundation


public enum MonsterState {
    case idle
    case chasing
}


public struct Monster: Actor {
    public let radius: Double = 0.45
    public var state: MonsterState = .idle
    public var position: Vector
    
    public let speed: Double = 0.5
    public var velocity = Vector(x: 0, y: 0)

    
    public init(position: Vector) {
        self.position = position
    }
}


public extension Monster {
   
    
    mutating func update(in world: World) {
        switch state {
        case .idle:
            if canSeePlayer(in: world) {
                state = .chasing
            }

            velocity = Vector(x: 0, y: 0)

        case .chasing:
            guard canSeePlayer(in: world) else {
                state = .idle
                velocity = Vector(x: 0, y: 0)
                break
            }

            let direction = world.player.position - position
            let distance = direction.length

            guard distance > 0 else {
                velocity = Vector(x: 0, y: 0)
                break
            }

            velocity = direction * (speed / distance)
        }
    }


    
    
    func canSeePlayer(in world: World) -> Bool {
        let direction = world.player.position - position
        let playerDistance = direction.length

        // Avoid dividing by zero if positions coincide
        guard playerDistance > 0 else {
            return true
        }

        let ray = Ray(
            origin: position,
            direction: direction / playerDistance
        )

        let wallHit = world.map.hitTest(ray)
        let wallDistance = (wallHit - position).length

        return wallDistance > playerDistance
    }

}
