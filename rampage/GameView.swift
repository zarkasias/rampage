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

    func makeUIView(context: Context) -> GameImageView {
        let imageView = GameImageView()

        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        imageView.isUserInteractionEnabled = true

        context.coordinator.start(imageView: imageView)

        return imageView
    }

    func updateUIView(
        _ uiView: GameImageView,
        context: Context
    ) {
        // SwiftUI updates aren't needed yet.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    static func dismantleUIView(
        _ uiView: GameImageView,
        coordinator: Coordinator
    ) {
        coordinator.stop()
    }

    // MARK: - Game Coordinator

    class Coordinator {
        private weak var imageView: GameImageView?
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

        func start(imageView: GameImageView) {
            self.imageView = imageView

            imageView.addGestureRecognizer(panGesture)

            let link = CADisplayLink(
                target: self,
                selector: #selector(update(_:))
            )

            link.add(to: .main, forMode: .common)
            displayLink = link
        }

        // MARK: - Touch Input

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

                vector /= max(
                    joystickRadius,
                    vector.length
                )

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

        // MARK: - Combined Input

        private var gameInputVector: Vector {
            guard let imageView else {
                return Vector(x: 0, y: 0)
            }

            // Keyboard takes priority when keys are held.
            if imageView.hasKeyboardInput {
                return imageView.keyboardVector
            }

            // Otherwise use the touch joystick.
            return inputVector
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

            // Read keyboard or joystick input
            let movement = gameInputVector

            // Calculate simulation steps
            let worldSteps = Int(
                (timeStep / worldTimeStep).rounded(.up)
            )

            if worldSteps > 0 {
                let stepDuration = timeStep / Double(worldSteps)

                // Calculate rotation
                let rotationAngle =
                    movement.x *
                    world.player.turningSpeed *
                    stepDuration

                let input = Input(
                    speed: -movement.y,
                    rotation: Rotation(
                        sine: sin(rotationAngle),
                        cosine: cos(rotationAngle)
                    )
                )

                // Update world
                for _ in 0 ..< worldSteps {
                    world.update(
                        timeStep: stepDuration,
                        input: input
                    )
                }
            }

            // Match the screen dimensions
            let width = max(
                1,
                Int(imageView.bounds.width)
            )

            let height = max(
                1,
                Int(imageView.bounds.height)
            )

            // Render first-person view
            var renderer = Renderer(
                width: width,
                height: height
            )

            renderer.draw(world)

            // Display frame
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
