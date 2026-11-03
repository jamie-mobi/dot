//
//  AppDynamicColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import SwiftUI

enum AppDynamicColor {
    // MARK: - Make

    static func nsColor(light: UInt32, dark: UInt32) -> NSColor {
        NSColor(name: nil) { appearance in
            rgb(isDark(appearance) ? dark : light)
        }
    }

    static func color(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: nsColor(light: light, dark: dark))
    }

    static func isDark(_ appearance: NSAppearance) -> Bool {
        appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }

    static func rgb(_ value: UInt32) -> NSColor {
        NSColor(
            srgbRed: CGFloat((value >> 16) & 0xFF) / 255,
            green: CGFloat((value >> 8) & 0xFF) / 255,
            blue: CGFloat(value & 0xFF) / 255,
            alpha: 1
        )
    }
}
