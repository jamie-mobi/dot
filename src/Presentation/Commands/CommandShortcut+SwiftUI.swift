//
//  CommandShortcut+SwiftUI.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import DotCore
import SwiftUI

extension CommandShortcut {
    // MARK: - SwiftUI

    var keyboardShortcut: KeyboardShortcut {
        KeyboardShortcut(keyEquivalent, modifiers: eventModifiers)
    }

    private var keyEquivalent: KeyEquivalent {
        switch key {
        case "tab":
            return .tab
        case "return":
            return .return
        case "space":
            return .space
        case "delete":
            return .delete
        case "escape":
            return .escape
        case "up":
            return .upArrow
        case "down":
            return .downArrow
        case "left":
            return .leftArrow
        case "right":
            return .rightArrow
        default:
            if let number = functionKeyNumber, let scalar = UnicodeScalar(NSF1FunctionKey + number - 1) {
                return KeyEquivalent(Character(scalar))
            }
            return KeyEquivalent(key.first ?? " ")
        }
    }

    private var eventModifiers: EventModifiers {
        var result: EventModifiers = []
        if modifiers.contains(.control) {
            result.insert(.control)
        }
        if modifiers.contains(.option) {
            result.insert(.option)
        }
        if modifiers.contains(.shift) {
            result.insert(.shift)
        }
        if modifiers.contains(.command) {
            result.insert(.command)
        }
        return result
    }

    // MARK: - Events

    init?(event: NSEvent) {
        guard let key = Self.key(of: event) else {
            return nil
        }

        var modifiers: Set<ShortcutModifier> = []
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.control) {
            modifiers.insert(.control)
        }
        if flags.contains(.option) {
            modifiers.insert(.option)
        }
        if flags.contains(.shift) {
            modifiers.insert(.shift)
        }
        if flags.contains(.command) {
            modifiers.insert(.command)
        }
        self.init(key, modifiers)
    }

    private static func key(of event: NSEvent) -> String? {
        switch event.keyCode {
        case 48:
            return "tab"
        case 36, 76:
            return "return"
        case 49:
            return "space"
        case 51:
            return "delete"
        case 126:
            return "up"
        case 125:
            return "down"
        case 123:
            return "left"
        case 124:
            return "right"
        default:
            break
        }

        guard let characters = event.characters(byApplyingModifiers: []), let scalar = characters.unicodeScalars.first else {
            return nil
        }

        let number = Int(scalar.value) - NSF1FunctionKey
        if (0 ..< 20).contains(number) {
            return "f\(number + 1)"
        }

        return scalar.value < 0xF700 ? characters.lowercased() : nil
    }
}
