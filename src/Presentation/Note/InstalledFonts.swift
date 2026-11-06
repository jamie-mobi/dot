//
//  InstalledFonts.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import DotCore

enum InstalledFonts {
    // MARK: - Families

    static let families = EditorFontFamilyUseCase.choices(from: NSFontManager.shared.availableFontFamilies)
    static let familySet = Set(families)

    static func family(saved: String) -> EditorFontFamily {
        EditorFontFamilyUseCase.family(saved: saved, installed: familySet)
    }
}
