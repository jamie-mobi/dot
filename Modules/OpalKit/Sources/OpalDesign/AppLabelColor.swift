//
//  AppLabelColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import SwiftUI

public enum AppLabelColor {
    // MARK: - Swatches

    public static let blue = AppDynamicColor.color(light: 0x3B6FD4, dark: 0x7FA4F0)
    public static let teal = AppDynamicColor.color(light: 0x23867A, dark: 0x4CC0AE)
    public static let purple = AppDynamicColor.color(light: 0x8455C9, dark: 0xB595EE)
    public static let amber = AppDynamicColor.color(light: 0xB7791F, dark: 0xE2AE4F)
    public static let green = AppDynamicColor.color(light: 0x4A8F3F, dark: 0x7DC26E)
    public static let slate = AppDynamicColor.color(light: 0x6B7280, dark: 0x9AA0AB)
    public static let grey = AppDynamicColor.color(light: 0x8A8F98, dark: 0xA0A5AE)

    // MARK: - No colour

    public static let neutral = grey
}
