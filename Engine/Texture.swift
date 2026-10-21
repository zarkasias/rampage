//
//  Texture.swift
//  Engine
//
//  Created by David Chambers on 10/21/26.
//

import Foundation

public enum Texture: String, CaseIterable {
    case crackWall
    case crackWall2
    case crackFloor
    case ceiling
    case wall
    case wall2
    
    case monster2
    
    case monsterIdle1, monsterIdle2
    case monsterIdle3, monsterIdle4

    case monsterWalk1, monsterWalk2
    case monsterWalk3, monsterWalk4
}

public struct Textures {
    private let textures: [Texture: Bitmap]
}

public extension Textures {
    init(loader: (String) -> Bitmap) {
        var textures = [Texture: Bitmap]()

        for texture in Texture.allCases {
            textures[texture] = loader(texture.rawValue)
        }

        self.init(textures: textures)
    }

    subscript(_ texture: Texture) -> Bitmap {
        return textures[texture]!
    }
}
