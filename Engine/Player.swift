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
    public let speed: Double = 2
    public let radius: Double = 0.25

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



public extension Player {
    
    func intersection(with map: Tilemap) -> Vector? {
        let minX = max(0, Int(rect.min.x))
        let maxX = min(map.width - 1, Int(rect.max.x))
        let minY = max(0, Int(rect.min.y))
        let maxY = min(map.height - 1, Int(rect.max.y))

        guard minX <= maxX, minY <= maxY else {
            return nil
        }

        var largestIntersection: Vector?

        for y in minY ... maxY {
            for x in minX ... maxX where map[x, y].isWall {
                let wallRect = Rect(
                    min: Vector(x: Double(x), y: Double(y)),
                    max: Vector(x: Double(x + 1), y: Double(y + 1))
                )

                if let intersection = rect.intersection(with: wallRect),
                   intersection.length > (largestIntersection?.length ?? 0) {
                    largestIntersection = intersection
                }
            }
        }

        return largestIntersection
    }

}

