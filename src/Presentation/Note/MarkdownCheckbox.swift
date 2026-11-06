//
//  MarkdownCheckbox.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit
import DotDesign

enum MarkdownCheckbox {
    // MARK: - Attribute

    static let key = NSAttributedString.Key("DotMarkdownCheckbox")

    // MARK: - Colour

    static func textColor(isDone: Bool, isActive: Bool) -> NSColor {
        guard isActive else {
            return .clear
        }

        return isDone ? AppKitColor.secondaryText : AppKitColor.accent
    }
}
