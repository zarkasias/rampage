//
//  GameView.swift
//  rampage
//
//  Created by David Chambers on 10/20/26.
//

import Foundation
import SwiftUI
import UIKit
import Engine



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


struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        
        context.coordinator.start(imageView: imageView)
        
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        // SwiftUI updates aren't needed yet.
    }
    
    func makeCoordinator() -> Coordinator {
            Coordinator()
    }
    
    class Coordinator {
        private weak var imageView: UIImageView?
        private var displayLink: CADisplayLink?
        private var world = World(map: loadMap())
        private var lastFrameTime: CFTimeInterval?
        private let joystickRadius: Double = 40
        private let maximumTimeStep: Double = 1.0 / 20.0
        private let worldTimeStep: Double = 1.0 / 120.0
        private let panGesture = UIPanGestureRecognizer()

        
        func start(imageView: UIImageView) {
            self.imageView = imageView
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(panGesture)
            
            let link = CADisplayLink(
                target: self,
                selector: #selector(update(_:))
            )
            
            link.add(to: .main, forMode: .common)
            displayLink = link
        }
        
        
        private var inputVector: Vector {
            switch panGesture.state {
            case .began, .changed:
                let translation = panGesture.translation(in: imageView)

                var vector = Vector(
                    x: Double(translation.x),
                    y: Double(translation.y)
                )

                vector /= max(joystickRadius, vector.length)

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

        
        
        @objc private func update(_ displayLink: CADisplayLink) {
            guard let imageView else { return }

            let currentTime = displayLink.timestamp

            
            let timeStep = lastFrameTime.map {
                min(maximumTimeStep, max(0, currentTime - $0))
            } ?? 0


            lastFrameTime = currentTime

            
            let input = Input(velocity: inputVector)

            let worldSteps = Int((timeStep / worldTimeStep).rounded(.up))

            if worldSteps > 0 {
                let stepDuration = timeStep / Double(worldSteps)

                for _ in 0 ..< worldSteps {
                    world.update(timeStep: stepDuration, input: input)
                }
            }


            let size = max(
                1,
                Int(min(imageView.bounds.width, imageView.bounds.height))
            )

            var renderer = Renderer(width: size, height: size)
            renderer.draw(world)

            imageView.image = UIImage(bitmap: renderer.bitmap)
        }

        
        func stop() {
            displayLink?.invalidate()
            displayLink = nil
        }
        
        deinit {
            stop()
        }
    }
    
    static func dismantleUIView(_ uiView: UIImageView, coordinator: Coordinator) {
        coordinator.stop()
    }
    
}
