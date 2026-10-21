//
//  Renderer.swift
//  Engine
//
//  Created by David Chambers on 10/20/26.
//



import Foundation

public struct Renderer {
    public private(set) var bitmap: Bitmap
    private let textures: Textures

    public init(
        width: Int,
        height: Int,
        textures: Textures
    ) {
        self.bitmap = Bitmap(
            width: width,
            height: height,
            color: .black
        )

        self.textures = textures
    }
}

public extension Renderer {

    mutating func draw(_ world: World) {

        let focalLength = 1.0
        let viewWidth =
            Double(bitmap.width) / Double(bitmap.height)

        let viewPlane =
            world.player.direction.orthogonal * viewWidth

        let viewCenter =
            world.player.position +
            world.player.direction * focalLength

        let viewStart = viewCenter - viewPlane / 2

        let columns = bitmap.width
        let step = viewPlane / Double(columns)
        var columnPosition = viewStart

        for x in 0 ..< columns {

            // MARK: - Raycasting

            let rayDirection =
                columnPosition - world.player.position

            let viewPlaneDistance = rayDirection.length

            let ray = Ray(
                origin: world.player.position,
                direction: rayDirection / viewPlaneDistance
            )

            // Find first wall hit
            let end = world.map.hitTest(ray)

            let wallDistance =
                (end - ray.origin).length

            // MARK: - Wall Projection

            let wallHeight = 1.0

            let distanceRatio =
                viewPlaneDistance / focalLength

            let perpendicular =
                wallDistance / distanceRatio

            let height =
                wallHeight * focalLength /
                perpendicular * Double(bitmap.height)

            // MARK: - Wall Texture

            let wallTexture: Bitmap
            let wallX: Double

            if end.x.rounded(.down) == end.x {
                wallTexture = textures[.crackWall]
                wallX = end.y - end.y.rounded(.down)
            } else {
                wallTexture = textures[.crackWall2]
                wallX = end.x - end.x.rounded(.down)
            }

            let textureX = min(
                wallTexture.width - 1,
                max(
                    0,
                    Int(wallX * Double(wallTexture.width))
                )
            )

            // Calculate top of wall
            let wallStart = Vector(
                x: Double(x),
                y: (Double(bitmap.height) - height) / 2 - 0.001
            )

            // Draw wall column
            bitmap.drawColumn(
                textureX,
                of: wallTexture,
                at: wallStart,
                height: height
            )

            // MARK: - Floor and Ceiling

            let floorTexture = textures[.crackFloor]
            let ceilingTexture = textures[.ceiling]

            let floorStart =
                Int(wallStart.y + height) + 1

            for y in max(
                0,
                min(floorStart, bitmap.height)
            ) ..< bitmap.height {

                // Convert screen position to normalized Y
                let normalizedY =
                    (Double(y) / Double(bitmap.height)) * 2 - 1

                guard normalizedY > 0 else {
                    continue
                }

                // Calculate distance from camera
                let floorDistance =
                    wallHeight * focalLength / normalizedY

                let distance =
                    floorDistance * distanceRatio

                // Find world position
                let mapPosition =
                    ray.origin + ray.direction * distance

                // Determine tile position
                let tileX = mapPosition.x.rounded(.down)
                let tileY = mapPosition.y.rounded(.down)

                // MARK: - Normalized Texture Coordinates

                let textureX = mapPosition.x - tileX
                let textureY = mapPosition.y - tileY

                // Draw floor pixel
                bitmap[x, y] = floorTexture[
                    normalized: textureX,
                    textureY
                ]

                // Draw mirrored ceiling pixel
                bitmap[x, bitmap.height - 1 - y] = ceilingTexture[
                    normalized: textureX,
                    textureY
                ]
            }

            // MARK: - Next Column

            columnPosition += step
        }
    }
}




