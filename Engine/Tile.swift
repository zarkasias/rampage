//
//  Tile.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation




public enum Tile: Int, Decodable {
    case floor = 0
    case wall = 1
    case crackWall = 2
    case crackFloor = 4
}

public extension Tile {

    var isWall: Bool {
        switch self {
        case .wall, .crackWall:
            return true

        case .floor, .crackFloor:
            return false
        }
    }

    var textures: [Texture] {
        switch self {
        case .floor:
            return [.crackFloor, .ceiling]

        case .crackFloor:
            return [.crackFloor, .ceiling]

        case .wall:
            return [.wall, .wall2]

        case .crackWall:
            return [.crackWall, .crackWall2]
        }
    }
}



