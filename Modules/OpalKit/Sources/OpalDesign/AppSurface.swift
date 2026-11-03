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

    static let fillLightAlpha: CGFloat = 0.045
    static let fillDarkAlpha: CGFloat = 0.06
    static let fill2LightAlpha: CGFloat = 0.07
    static let fill2DarkAlpha: CGFloat = 0.10
    static let ink: UInt32 = 0x000000
    static let light: UInt32 = 0xFFFFFF

    // MARK: - Colours

    static var fill: NSColor {
        AppDynamicColor.overlay(light: ink, lightAlpha: fillLightAlpha, dark: light, darkAlpha: fillDarkAlpha)
    }

    static var fill2: NSColor {
        AppDynamicColor.overlay(light: ink, lightAlpha: fill2LightAlpha, dark: light, darkAlpha: fill2DarkAlpha)
    }

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
