//
//  AppBrandColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import SwiftUI

public enum AppBrandColor {
    // MARK: - Opal rose

    public static let accent = AppDynamicColor.color(light: 0xB8336F, dark: 0xF07AAE)
    public static let onAccent = AppDynamicColor.color(light: 0xFFFFFF, dark: 0x2A0E1B)

    // MARK: - AppKit

    public static var accentNSColor: NSColor { AppDynamicColor.nsColor(light: 0xB8336F, dark: 0xF07AAE) }
    public static var onAccentNSColor: NSColor { AppDynamicColor.nsColor(light: 0xFFFFFF, dark: 0x2A0E1B) }
}
