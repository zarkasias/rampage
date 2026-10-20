//
//  Tile.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation


public enum Tile: Int, Decodable {
    case floor
    case wall
}

public extension Tile {
    var isWall: Bool {
        switch self {
        case .wall:
            return true
        case .floor:
            return false
        }
    }
}

