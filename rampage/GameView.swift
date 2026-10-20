//
//  GameView.swift
//  rampage
//
//  Created by David Chambers on 10/20/26.
//


import SwiftUI
import UIKit
import Engine

// MARK: - Map Loading

private func loadMap() -> Tilemap {
    let jsonURL = Bundle.main.url(
        forResource: "Map",
        withExtension: "json"
    )!

    let jsonData = try! Data(contentsOf: jsonURL)

    return try! JSONDecoder().decode(
        Tilemap.self,
        from: jsonData
    )
}

// MARK: - Game View

struct GameView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()

        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        imageView.isUserInteractionEnabled = true

        context.coordinator.start(imageView: imageView)

        return imageView
    }

    func updateUIView(
        _ uiView: UIImageView,
        context: Context
    ) {
        // SwiftUI updates aren't needed yet.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    static func dismantleUIView(
        _ uiView: UIImageView,
        coordinator: Coordinator
    ) {
        coordinator.stop()
    }

    // MARK: - Game Coordinator

    class Coordinator {
        private weak var imageView: UIImageView?
        private var displayLink: CADisplayLink?

        // Game state
        private var world = World(map: loadMap())
        private var lastFrameTime: CFTimeInterval?

        // Frame timing
        private let maximumTimeStep: Double = 1.0 / 20.0
        private let worldTimeStep: Double = 1.0 / 120.0

        // Touch input
        private let joystickRadius: Double = 40
        private let panGesture = UIPanGestureRecognizer()

        // MARK: - Start

        func start(imageView: UIImageView) {
            self.imageView = imageView

            imageView.addGestureRecognizer(panGesture)

            let link = CADisplayLink(
                target: self,
                selector: #selector(update(_:))
            )

            link.add(to: .main, forMode: .common)
            displayLink = link
        }

        // MARK: - Input

        private var inputVector: Vector {
            switch panGesture.state {
            case .began, .changed:
                let translation = panGesture.translation(
                    in: imageView
                )

                var vector = Vector(
                    x: Double(translation.x),
                    y: Double(translation.y)
                )

                // Normalize and clamp input to length <= 1
                vector /= max(joystickRadius, vector.length)

                // Move the joystick origin as the finger drags
                panGesture.setTranslation(
                    CGPoint(
                        x: vector.x * joystickRadius,
                        y: vector.y * joystickRadius
                    ),
                    in: imageView
                )

                return vector

            default:
                return Vector(x: 0, y: 0)
            }
        }

        // MARK: - Game Loop

        @objc private func update(_ displayLink: CADisplayLink) {
            guard let imageView else { return }

            let currentTime = displayLink.timestamp

            let timeStep = lastFrameTime.map {
                min(
                    maximumTimeStep,
                    max(0, currentTime - $0)
                )
            } ?? 0

            lastFrameTime = currentTime

            // Read joystick input once per frame
            let joystick = inputVector

            // Calculate simulation steps
            let worldSteps = Int(
                (timeStep / worldTimeStep).rounded(.up)
            )

            if worldSteps > 0 {
                let stepDuration = timeStep / Double(worldSteps)

                // Convert horizontal joystick movement
                // into rotation measured in radians
                let rotationAngle =
                    joystick.x *
                    world.player.turningSpeed *
                    stepDuration

                // Convert input into forward/backward
                // movement and rotation
                let input = Input(
                    speed: -joystick.y,
                    rotation: Rotation(
                        sine: sin(rotationAngle),
                        cosine: cos(rotationAngle)
                    )
                )

                // Update the world in smaller steps
                for _ in 0 ..< worldSteps {
                    world.update(
                        timeStep: stepDuration,
                        input: input
                    )
                }
            }

            // Determine bitmap resolution
            let size = max(
                1,
                Int(min(
                    imageView.bounds.width,
                    imageView.bounds.height
                ))
            )

            // Render the world
            var renderer = Renderer(
                width: size,
                height: size
            )

            renderer.draw(world)

            // Display the resulting bitmap
            imageView.image = UIImage(bitmap: renderer.bitmap)
        }

        // MARK: - Stop

        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            lastFrameTime = nil
        }

        deinit {
            stop()
        }
    }
}

