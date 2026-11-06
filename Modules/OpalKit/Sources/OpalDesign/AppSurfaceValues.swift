//
//  AppSurfaceValues.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import AppKit

enum AppSurfaceValues {
    // MARK: - Ink

    static let black: UInt32 = 0x000000
    static let white: UInt32 = 0xFFFFFF

    // MARK: - Surfaces

    static let editorLight: UInt32 = 0xFFFFFF
    static let editorDark: UInt32 = 0x1C1C20
    static let editorAlpha: CGFloat = 0.88
    static let surfaceDark: UInt32 = 0x2A2A2F
    static let fieldLightAlpha: CGFloat = 0.92
    static let fieldDarkAlpha: CGFloat = 0.07
    static let popoverLight: UInt32 = 0xFAFAFC
    static let popoverDark: UInt32 = 0x2A2A30
    static let popoverAlpha: CGFloat = 0.84
    static let windowLight: UInt32 = 0xF4F5F7
    static let windowDark: UInt32 = 0x1E1E22
    static let windowLightAlpha: CGFloat = 0.64
    static let windowDarkAlpha: CGFloat = 0.62

    // MARK: - Fills and lines

    static let fillLightAlpha: CGFloat = 0.045
    static let fillDarkAlpha: CGFloat = 0.06
    static let strongFillLightAlpha: CGFloat = 0.07
    static let strongFillDarkAlpha: CGFloat = 0.10
    static let selectionLightAlpha: CGFloat = 0.065
    static let selectionDarkAlpha: CGFloat = 0.09
    static let lineAlpha: CGFloat = 0.08
    static let strongLineLightAlpha: CGFloat = 0.13
    static let strongLineDarkAlpha: CGFloat = 0.14
    static let scrimLight: UInt32 = 0x14161A
    static let scrimLightAlpha: CGFloat = 0.10
    static let scrimDarkAlpha: CGFloat = 0.25
    static let cardShadowLightAlpha: CGFloat = 0.04
    static let cardShadowDarkAlpha: CGFloat = 0.20
    static let popoverShadowLightAlpha: CGFloat = 0.28
    static let popoverShadowDarkAlpha: CGFloat = 0.60

    // MARK: - App icon

    static let iconTop: UInt32 = 0x2B2B30
    static let iconBottom: UInt32 = 0x0E0E10

    // MARK: - Text

    static let textLight: UInt32 = 0x1D1D1F
    static let textDark: UInt32 = 0xF2F2F4
    static let secondaryTextLight: UInt32 = 0x55555C
    static let secondaryTextDark: UInt32 = 0xB4B4BC
    static let quietTextLight: UInt32 = 0x6B6B73
    static let quietTextDark: UInt32 = 0x9A9AA3

    // MARK: - Accent tints

    static let accentSoftLightAlpha: CGFloat = 0.10
    static let accentSoftDarkAlpha: CGFloat = 0.15
    static let searchMatchLightAlpha: CGFloat = 0.16
    static let searchMatchDarkAlpha: CGFloat = 0.26
}
