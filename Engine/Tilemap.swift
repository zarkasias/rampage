//
//  Tilemap.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation


public struct Tilemap: Decodable {
    private let tiles: [Tile]
    public let things: [Thing]
    public let width: Int
}

public extension Tilemap {
    var height: Int {
        return tiles.count / width
    }

    var size: Vector {
        return Vector(
            x: Double(width),
            y: Double(height)
        )
    }

    subscript(x: Int, y: Int) -> Tile {
        return tiles[y * width + x]
    }
}

