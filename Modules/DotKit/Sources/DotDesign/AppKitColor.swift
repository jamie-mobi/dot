//
//  AppKitColor.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit

public enum AppKitColor {
    // MARK: - Accent

    public static var accent: NSColor {
        NSColor(name: nil) { appearance in
            switch AppAccent.current {
            case .dot:
                AppDynamicColor.rgb(AppDynamicColor.isDark(appearance) ? AppBrandColor.accentDark : AppBrandColor.accentLight)
            case .system:
                NSColor.controlAccentColor
            }
        }
    }

    public static var onAccent: NSColor {
        NSColor(name: nil) { appearance in
            switch AppAccent.current {
            case .dot:
                AppDynamicColor.rgb(AppDynamicColor.isDark(appearance) ? AppBrandColor.onAccentDark : AppBrandColor.onAccentLight)
            case .system:
                NSColor.white
            }
        }
    }

    public static var accentSoft: NSColor {
        accentTint(light: AppSurfaceValues.accentSoftLightAlpha, dark: AppSurfaceValues.accentSoftDarkAlpha)
    }

    public static var searchMatch: NSColor {
        accentTint(light: AppSurfaceValues.searchMatchLightAlpha, dark: AppSurfaceValues.searchMatchDarkAlpha)
    }

    public static var tagFill: NSColor { accentSoft }
    public static var mark: NSColor { searchMatch }
    public static var calloutFill: NSColor { accent.withAlphaComponent(AppOpacity.callout) }
    public static var unresolvedLink: NSColor { accent.withAlphaComponent(AppOpacity.unresolved) }

    // MARK: - Surfaces

    public static var editorBackground: NSColor {
        AppDynamicColor.translucent(light: AppSurfaceValues.editorLight, lightAlpha: AppSurfaceValues.editorAlpha, dark: AppSurfaceValues.editorDark, darkAlpha: AppSurfaceValues.editorAlpha)
    }

    public static var window: NSColor {
        AppDynamicColor.translucent(light: AppSurfaceValues.windowLight, lightAlpha: AppSurfaceValues.windowLightAlpha, dark: AppSurfaceValues.windowDark, darkAlpha: AppSurfaceValues.windowDarkAlpha)
    }

    public static var surface: NSColor {
        AppDynamicColor.nsColor(light: AppSurfaceValues.white, dark: AppSurfaceValues.surfaceDark)
    }

    public static var field: NSColor {
        AppDynamicColor.overlay(light: AppSurfaceValues.white, lightAlpha: AppSurfaceValues.fieldLightAlpha, dark: AppSurfaceValues.white, darkAlpha: AppSurfaceValues.fieldDarkAlpha)
    }

    public static var popover: NSColor {
        AppDynamicColor.translucent(light: AppSurfaceValues.popoverLight, lightAlpha: AppSurfaceValues.popoverAlpha, dark: AppSurfaceValues.popoverDark, darkAlpha: AppSurfaceValues.popoverAlpha)
    }

    public static var fill: NSColor {
        ink(light: AppSurfaceValues.fillLightAlpha, dark: AppSurfaceValues.fillDarkAlpha)
    }

    public static var strongFill: NSColor {
        ink(light: AppSurfaceValues.strongFillLightAlpha, dark: AppSurfaceValues.strongFillDarkAlpha)
    }

    public static var selection: NSColor {
        ink(light: AppSurfaceValues.selectionLightAlpha, dark: AppSurfaceValues.selectionDarkAlpha)
    }

    public static var line: NSColor {
        ink(light: AppSurfaceValues.lineAlpha, dark: AppSurfaceValues.lineAlpha)
    }

    public static var strongLine: NSColor {
        ink(light: AppSurfaceValues.strongLineLightAlpha, dark: AppSurfaceValues.strongLineDarkAlpha)
    }

    public static var divider: NSColor { strongLine }

    // MARK: - Text

    public static var text: NSColor {
        AppDynamicColor.nsColor(light: AppSurfaceValues.textLight, dark: AppSurfaceValues.textDark)
    }

    public static var secondaryText: NSColor {
        AppDynamicColor.nsColor(light: AppSurfaceValues.secondaryTextLight, dark: AppSurfaceValues.secondaryTextDark)
    }

    public static var quietText: NSColor {
        AppDynamicColor.nsColor(light: AppSurfaceValues.quietTextLight, dark: AppSurfaceValues.quietTextDark)
    }

    // MARK: - Markdown

    public static var highlight: NSColor { NSColor.systemYellow.withAlphaComponent(AppOpacity.highlight) }
    public static var codeFill: NSColor { fill }

    // MARK: - Private

    private static func ink(light: CGFloat, dark: CGFloat) -> NSColor {
        AppDynamicColor.overlay(light: AppSurfaceValues.black, lightAlpha: light, dark: AppSurfaceValues.white, darkAlpha: dark)
    }

    private static func accentTint(light: CGFloat, dark: CGFloat) -> NSColor {
        NSColor(name: nil) { appearance in
            let isDark = AppDynamicColor.isDark(appearance)
            var base = NSColor.clear
            appearance.performAsCurrentDrawingAppearance {
                base = accent.usingColorSpace(.sRGB) ?? accent
            }
            return base.withAlphaComponent(isDark ? dark : light)
        }
    }
}
