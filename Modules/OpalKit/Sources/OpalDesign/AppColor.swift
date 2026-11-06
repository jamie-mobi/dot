//
//  AppColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit
import SwiftUI

public enum AppColor {
    // MARK: - Surfaces

    public static let editorBackground = Color(nsColor: AppKitColor.editorBackground)
    public static let window = Color(nsColor: AppKitColor.window)
    public static let surface = Color(nsColor: AppKitColor.surface)
    public static let field = Color(nsColor: AppKitColor.field)
    public static let popover = Color(nsColor: AppKitColor.popover)
    public static let fill = Color(nsColor: AppKitColor.fill)
    public static let strongFill = Color(nsColor: AppKitColor.strongFill)
    public static let selection = Color(nsColor: AppKitColor.selection)
    public static let line = Color(nsColor: AppKitColor.line)
    public static let strongLine = Color(nsColor: AppKitColor.strongLine)
    public static let scrim = AppDynamicColor.color(light: AppSurfaceValues.scrimLight, lightAlpha: AppSurfaceValues.scrimLightAlpha, dark: AppSurfaceValues.black, darkAlpha: AppSurfaceValues.scrimDarkAlpha)
    public static let cardShadow = AppDynamicColor.color(light: AppSurfaceValues.black, lightAlpha: AppSurfaceValues.cardShadowLightAlpha, dark: AppSurfaceValues.black, darkAlpha: AppSurfaceValues.cardShadowDarkAlpha)
    public static let fadeMask = Color.black
    public static let popoverShadow = AppDynamicColor.color(light: AppSurfaceValues.black, lightAlpha: AppSurfaceValues.popoverShadowLightAlpha, dark: AppSurfaceValues.black, darkAlpha: AppSurfaceValues.popoverShadowDarkAlpha)

    // MARK: - App icon

    public static let iconTop = AppDynamicColor.color(light: AppSurfaceValues.iconTop, dark: AppSurfaceValues.iconTop)
    public static let iconBottom = AppDynamicColor.color(light: AppSurfaceValues.iconBottom, dark: AppSurfaceValues.iconBottom)
    public static let iconSymbol = AppDynamicColor.color(light: AppSurfaceValues.white, dark: AppSurfaceValues.white)

    // MARK: - Text

    public static let text = Color(nsColor: AppKitColor.text)
    public static let secondaryText = Color(nsColor: AppKitColor.secondaryText)
    public static let quietText = Color(nsColor: AppKitColor.quietText)

    // MARK: - Accent

    public static let accent = Color(nsColor: AppKitColor.accent)
    public static let accentSoft = Color(nsColor: AppKitColor.accentSoft)
    public static let onAccent = Color(nsColor: AppKitColor.onAccent)
    public static let searchMatch = Color(nsColor: AppKitColor.searchMatch)
    public static let tagFill = accentSoft

    // MARK: - Markdown

    public static let mark = searchMatch
    public static let codeFill = Color(nsColor: AppKitColor.codeFill)
    public static let calloutFill = Color(nsColor: AppKitColor.calloutFill)
    public static let unresolvedLink = Color(nsColor: AppKitColor.unresolvedLink)
    public static let highlight = Color(nsColor: AppKitColor.highlight)
    public static let failure = Color.red
    public static let codeKeyword = Color.purple
    public static let codeString = Color.red
    public static let codeNumber = Color.blue
    public static let codeComment = quietText
}
