//
//  AppBrandColor.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit

public enum AppBrandColor {
    // MARK: - Dot rose

    static let accentLight: UInt32 = 0xB8336F
    static let accentDark: UInt32 = 0xF07AAE
    static let onAccentLight: UInt32 = 0xFFFFFF
    static let onAccentDark: UInt32 = 0x2A0E1B

    // MARK: - AppKit

    public static var accent: NSColor {
        AppDynamicColor.nsColor(light: accentLight, dark: accentDark)
    }

    public static var onAccent: NSColor {
        AppDynamicColor.nsColor(light: onAccentLight, dark: onAccentDark)
    }
}
