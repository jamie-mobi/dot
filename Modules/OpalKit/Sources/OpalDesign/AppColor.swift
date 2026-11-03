//
//  AppColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit
import SwiftUI

public enum AppColor {
    public static let accent = Color(nsColor: AppKitColor.accent)
    public static let onAccent = Color(nsColor: AppKitColor.onAccent)
    public static let editorBackground = Color(nsColor: AppKitColor.editorBackground)
    public static let window = Color(nsColor: AppKitColor.window)
    public static let surface = Color(nsColor: AppKitColor.surface)
    public static let fill = Color(nsColor: AppKitColor.fill)
    public static let fill2 = Color(nsColor: AppKitColor.fill2)
    public static let accentSoft = Color(nsColor: AppKitColor.accentSoft)
    public static let mark = Color(nsColor: AppKitColor.mark)
    public static let cardShadow = Color.black.opacity(AppOpacity.cardShadow)
    public static let codeFill = Color(nsColor: .quaternarySystemFill)
    public static let calloutFill = accent.opacity(AppOpacity.callout)
    public static let tagFill = accent.opacity(AppOpacity.tag)
    public static let unresolvedLink = accent.opacity(AppOpacity.unresolved)
    public static let searchMatch = accent.opacity(AppOpacity.searchMatch)
    public static let highlight = Color.yellow.opacity(AppOpacity.highlight)
    public static let failure = Color.red
    public static let codeKeyword = Color.purple
    public static let codeString = Color.red
    public static let codeNumber = Color.blue
    public static let codeComment = Color.secondary
}
