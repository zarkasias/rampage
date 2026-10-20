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
        
        func start(imageView: UIImageView) {
            self.imageView = imageView
            
            let link = CADisplayLink(
                target: self,
                selector: #selector(update(_:))
            )
            
            link.add(to: .main, forMode: .common)
            displayLink = link
        }
        
        @objc private func update(_ displayLink: CADisplayLink) {
            guard let imageView else { return }
            
            let currentTime = displayLink.timestamp
             let timeStep = lastFrameTime.map {
                 max(0, currentTime - $0)
             } ?? 0

             lastFrameTime = currentTime
            
            world.update(timeStep: timeStep)
            
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
