//
//  FolderColourUseCaseTests.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Testing
@testable import OpalCore

@Suite("FolderColourUseCase", .tags(.domain))
struct FolderColourUseCaseTests {
    // MARK: - Tests

    @Test("a Note takes the colour of its nearest coloured Folder")
    func nearest() {
        let colours: [NotePath: FolderColour] = [NotePath("Projects"): .blue, NotePath("Projects/Opal"): .purple]
        #expect(FolderColourUseCase.colour(for: NotePath("Projects/Opal/Roadmap.md"), in: colours) == .purple)
        #expect(FolderColourUseCase.colour(for: NotePath("Projects/Garden.md"), in: colours) == .blue)
        #expect(FolderColourUseCase.colour(for: NotePath("Soil.md"), in: colours) == nil)
    }

    @Test("a Folder with no choice has no colour: the reference's defaults are not built in")
    func noDefaults() {
        #expect(FolderColourUseCase.colour(for: NotePath("Projects"), in: [:]) == nil)
        #expect(FolderColourUseCase.colour(for: NotePath("Daily Notes/2026-11-03.md"), in: [:]) == nil)
    }

    @Test("moving a Folder carries its colour and the colours inside it")
    func moving() {
        let colours: [NotePath: FolderColour] = [NotePath("Projects"): .blue, NotePath("Projects/Opal"): .purple, NotePath("Areas"): .teal]
        let moved = FolderColourUseCase.moving(colours, from: NotePath("Projects"), to: NotePath("Work"))
        #expect(moved == [NotePath("Work"): .blue, NotePath("Work/Opal"): .purple, NotePath("Areas"): .teal])
    }

    @Test("a Folder whose name only starts the same is not moved")
    func prefixIsComponents() {
        let colours: [NotePath: FolderColour] = [NotePath("Projects Old"): .amber]
        #expect(FolderColourUseCase.moving(colours, from: NotePath("Projects"), to: NotePath("Work")) == colours)
    }

    @Test("forgetting a Folder drops its colour and the colours inside it")
    func forgetting() {
        let colours: [NotePath: FolderColour] = [NotePath("Projects"): .blue, NotePath("Projects/Opal"): .purple, NotePath("Areas"): .teal]
        #expect(FolderColourUseCase.forgetting(NotePath("Projects"), in: colours) == [NotePath("Areas"): .teal])
    }
}
