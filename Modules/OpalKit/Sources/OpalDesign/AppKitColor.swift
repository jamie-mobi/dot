//
//  AppKitColor.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit

public enum AppKitColor {
    public static var accent: NSColor {
        NSColor(name: nil) { appearance in
            switch AppAccent.current {
            case .opal:
                AppDynamicColor.rgb(AppDynamicColor.isDark(appearance) ? AppBrandColor.accentDark : AppBrandColor.accentLight)
            case .system:
                NSColor.controlAccentColor
            }
        }
    }

    public static var onAccent: NSColor {
        NSColor(name: nil) { appearance in
            switch AppAccent.current {
            case .opal:
                AppDynamicColor.rgb(AppDynamicColor.isDark(appearance) ? AppBrandColor.onAccentDark : AppBrandColor.onAccentLight)
            case .system:
                NSColor.white
            }
        }
    }

    public static var accentSoft: NSColor { accent.withAlphaComponent(AppOpacity.accentSoft) }
    public static var calloutFill: NSColor { accent.withAlphaComponent(AppOpacity.callout) }
    public static var tagFill: NSColor { accent.withAlphaComponent(AppOpacity.tag) }
    public static var unresolvedLink: NSColor { accent.withAlphaComponent(AppOpacity.unresolved) }
    public static var highlight: NSColor { NSColor.systemYellow.withAlphaComponent(AppOpacity.highlight) }
    public static var codeFill: NSColor { NSColor.quaternarySystemFill }
    public static var divider: NSColor { NSColor.separatorColor }
    public static var text: NSColor { NSColor.textColor }
    public static var secondaryText: NSColor { NSColor.secondaryLabelColor }
    public static var quietText: NSColor { NSColor.quaternaryLabelColor }
    public static var editorBackground: NSColor { AppSurface.paper }
    public static var window: NSColor { AppSurface.window }
    public static var surface: NSColor { AppSurface.surface }
}
