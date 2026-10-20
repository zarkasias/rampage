//
//  GameImageView.swift
//  rampage
//
//  Created by David Chambers on 10/20/26.
//

import Foundation

import UIKit
import Engine

final class GameImageView: UIImageView {

    private var pressedKeys = Set<UIKeyboardHIDUsage>()

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            becomeFirstResponder()
        } else {
            pressedKeys.removeAll()
        }
    }

    // MARK: - Keyboard Input

    var keyboardVector: Vector {
        var x = 0.0
        var y = 0.0

        if pressedKeys.contains(.keyboardUpArrow) {
            y -= 1
        }

        if pressedKeys.contains(.keyboardDownArrow) {
            y += 1
        }

        if pressedKeys.contains(.keyboardLeftArrow) {
            x -= 1
        }

        if pressedKeys.contains(.keyboardRightArrow) {
            x += 1
        }

        let vector = Vector(x: x, y: y)
        let length = vector.length

        if length > 1 {
            return vector / length
        }

        return vector
    }

    var hasKeyboardInput: Bool {
        !pressedKeys.isEmpty
    }

    // MARK: - Key Presses

    override func pressesBegan(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        var unhandled = Set<UIPress>()

        for press in presses {
            guard let key = press.key,
                  isArrowKey(key.keyCode) else {
                unhandled.insert(press)
                continue
            }

            pressedKeys.insert(key.keyCode)
        }

        if !unhandled.isEmpty {
            super.pressesBegan(unhandled, with: event)
        }
    }

    override func pressesEnded(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        releaseKeys(presses)

        let unhandled = presses.filter {
            guard let key = $0.key else { return true }
            return !isArrowKey(key.keyCode)
        }

        if !unhandled.isEmpty {
            super.pressesEnded(
                Set(unhandled),
                with: event
            )
        }
    }

    override func pressesCancelled(
        _ presses: Set<UIPress>,
        with event: UIPressesEvent?
    ) {
        releaseKeys(presses)

        let unhandled = presses.filter {
            guard let key = $0.key else { return true }
            return !isArrowKey(key.keyCode)
        }

        if !unhandled.isEmpty {
            super.pressesCancelled(
                Set(unhandled),
                with: event
            )
        }
    }

    // MARK: - Helpers

    private func releaseKeys(_ presses: Set<UIPress>) {
        for press in presses {
            if let key = press.key {
                pressedKeys.remove(key.keyCode)
            }
        }
    }

    private func isArrowKey(
        _ key: UIKeyboardHIDUsage
    ) -> Bool {
        switch key {
        case .keyboardUpArrow,
             .keyboardDownArrow,
             .keyboardLeftArrow,
             .keyboardRightArrow:
            return true

        default:
            return false
        }
    }
}
