//
//  AppAccentTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import OpalDesign
import Testing

@Suite("Accent", .serialized)
struct AppAccentTests {
    // MARK: - Helpers

    private func resolved(_ color: NSColor, dark: Bool) -> NSColor? {
        let appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        var result: NSColor?
        appearance?.performAsCurrentDrawingAppearance {
            result = color.usingColorSpace(.sRGB)
        }
        return result
    }

    private func hex(_ color: NSColor?) -> UInt32? {
        guard let color else {
            return nil
        }

        let red = UInt32((color.redComponent * 255).rounded())
        let green = UInt32((color.greenComponent * 255).rounded())
        let blue = UInt32((color.blueComponent * 255).rounded())
        return red << 16 | green << 8 | blue
    }

    // MARK: - Tests

    @Test("the accent is Opal when nothing is saved")
    func defaultIsOpal() {
        #expect(AppAccent.defaultValue == .opal)
        #expect(AppAccent(rawValue: AppAccent.opal.rawValue) == .opal)
        #expect(AppAccent.key == "accent")
    }

    @Test("Opal resolves to opal-rose in light and dark, with its own text colour")
    func opalRose() {
        AppAccent.current = .opal
        defer { AppAccent.current = .defaultValue }
        #expect(hex(resolved(AppKitColor.accent, dark: false)) == 0xB8336F)
        #expect(hex(resolved(AppKitColor.accent, dark: true)) == 0xF07AAE)
        #expect(hex(resolved(AppKitColor.onAccent, dark: false)) == 0xFFFFFF)
        #expect(hex(resolved(AppKitColor.onAccent, dark: true)) == 0x2A0E1B)
    }

    @Test("System resolves to the macOS accent with white text")
    func systemAccent() {
        AppAccent.current = .system
        defer { AppAccent.current = .defaultValue }
        #expect(hex(resolved(AppKitColor.accent, dark: false)) == hex(resolved(NSColor.controlAccentColor, dark: false)))
        #expect(hex(resolved(AppKitColor.onAccent, dark: false)) == 0xFFFFFF)
    }

    @Test("accent roles follow the accent")
    func rolesFollow() {
        AppAccent.current = .opal
        defer { AppAccent.current = .defaultValue }
        let tag = resolved(AppKitColor.tagFill, dark: false)
        #expect(hex(tag.map { $0.withAlphaComponent(1) }) == 0xB8336F)
    }
}
