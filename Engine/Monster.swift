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
    
    public var animation: Animation = .monsterIdle

    
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
                animation = .monsterWalk
            }

            velocity = Vector(x: 0, y: 0)

        case .chasing:
            guard canSeePlayer(in: world) else {
                state = .idle
                animation = .monsterIdle
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


public extension Animation {
    static let monsterIdle = Animation(
        frames: [
            .monsterIdle1,
            .monsterIdle2,
            .monsterIdle3,
            .monsterIdle4
        ],
        duration: 0.8
    )

    static let monsterWalk = Animation(
        frames: [
            .monsterWalk1,
            .monsterWalk2,
            .monsterWalk3,
            .monsterWalk4
        ],
        duration: 0.5
    )
}

