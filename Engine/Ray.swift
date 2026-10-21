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


public extension Ray {
    var slopeIntercept: (
        slope: Double,
        intercept: Double
    ) {
        let slope = direction.y / direction.x
        let intercept = origin.y - slope * origin.x

        return (slope, intercept)
    }
}

