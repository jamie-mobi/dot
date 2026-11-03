//
//  AppSurface.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit

enum AppSurface {
    // MARK: - Values

    static let windowLight: UInt32 = 0xF4F5F7
    static let windowDark: UInt32 = 0x1E1E22
    static let windowLightAlpha: CGFloat = 0.64
    static let windowDarkAlpha: CGFloat = 0.62

    static let paperLight: UInt32 = 0xFFFFFF
    static let paperDark: UInt32 = 0x1C1C20
    static let paperAlpha: CGFloat = 0.86

    static let surfaceLight: UInt32 = 0xFFFFFF
    static let surfaceDark: UInt32 = 0x2A2A2F

    // MARK: - Colours

    static var surface: NSColor {
        AppDynamicColor.nsColor(light: surfaceLight, dark: surfaceDark)
    }

    static var window: NSColor {
        AppDynamicColor.translucent(light: windowLight, lightAlpha: windowLightAlpha, dark: windowDark, darkAlpha: windowDarkAlpha)
    }

    static var paper: NSColor {
        AppDynamicColor.translucent(light: paperLight, lightAlpha: paperAlpha, dark: paperDark, darkAlpha: paperAlpha)
    }
}
