//
//  EditorFontFamilyUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Testing
@testable import OpalCore

@Suite("EditorFontFamilyUseCase", .tags(.domain))
struct EditorFontFamilyUseCaseTests {
    @Test("no saved family keeps the saved design")
    func noFamily() {
        #expect(EditorFontFamilyUseCase.family(saved: "", installed: ["Georgia"]) == .none)
    }

    @Test("an installed family is used")
    func installed() {
        #expect(EditorFontFamilyUseCase.family(saved: "Georgia", installed: ["Georgia"]) == .installed("Georgia"))
    }

    @Test("a family no longer installed is missing, and its name stays")
    func missing() {
        #expect(EditorFontFamilyUseCase.family(saved: "Georgia", installed: ["Menlo"]) == .missing("Georgia"))
    }

    @Test("the list is sorted, without duplicates or hidden system families")
    func choices() {
        #expect(EditorFontFamilyUseCase.choices(from: ["Menlo", ".SF NS", "Georgia", "Menlo", "avenir"]) == ["avenir", "Georgia", "Menlo"])
    }
}
