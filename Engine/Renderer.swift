//
//  Renderer.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//

import Foundation


public struct Renderer {
    public private(set) var bitmap: Bitmap

    public init(width: Int, height: Int) {
        self.bitmap = Bitmap(
            width: width,
            height: height,
            color: .black
        )
    }
}

public extension Renderer {
    mutating func draw(_ world: World) {
        let scale = Double(bitmap.height) / world.size.y

        // Draw map
        for y in 0 ..< world.map.height {
            for x in 0 ..< world.map.width
                where world.map[x, y].isWall {

                let rect = Rect(
                    min: Vector(
                        x: Double(x),
                        y: Double(y)
                    ) * scale,
                    max: Vector(
                        x: Double(x + 1),
                        y: Double(y + 1)
                    ) * scale
                )

                bitmap.fill(rect: rect, color: .white)
            }
        }

        // Draw player
        var rect = world.player.rect
        rect.min *= scale
        rect.max *= scale

        bitmap.fill(rect: rect, color: .blue)
        
      
        
        
        // Draw view plane
        let focalLength = 1.0
        let viewWidth = 1.0

        let viewPlane = world.player.direction.orthogonal * viewWidth

        let viewCenter =
            world.player.position + world.player.direction * focalLength

        let viewStart = viewCenter - viewPlane / 2
        let viewEnd = viewStart + viewPlane

        bitmap.drawLine(
            from: viewStart * scale,
            to: viewEnd * scale,
            color: .red
        )
        
        
        // Cast rays
        let columns = 10
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart

        for _ in 0 ..< columns {
            let rayDirection = columnPosition - world.player.position
            let viewPlaneDistance = rayDirection.length

            let ray = Ray(
                origin: world.player.position,
                direction: rayDirection / viewPlaneDistance
            )

            let end = world.map.hitTest(ray)

            bitmap.drawLine(
                from: ray.origin * scale,
                to: end * scale,
                color: .green
            )

            columnPosition += step
        }


    }
}


