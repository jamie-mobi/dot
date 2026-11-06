//
//  OpenNoteUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Open a Note file", .tags(.domain))
struct OpenNoteUseCaseTests {
    // MARK: - Fixtures

    private let garden = URL(filePath: "/Users/me/Notes/Garden", directoryHint: .isDirectory)
    private let work = URL(filePath: "/Users/me/Notes/Garden/Work", directoryHint: .isDirectory)
    private let left = UUID()
    private let right = UUID()

    // MARK: - Path

    @Test("a Markdown file inside the Pack becomes its Note path")
    func pathInside() {
        #expect(OpenNoteUseCase.path(of: URL(filePath: "/Users/me/Notes/Garden/Reading/The Soil Book.md"), in: garden) == NotePath("Reading/The Soil Book.md"))
    }

    @Test("a file outside the Pack, a file that is not Markdown, or a file in a hidden folder has no Note path", arguments: [
        "/Users/me/Notes/Other/Soil.md",
        "/Users/me/Notes/GardenTwo/Soil.md",
        "/Users/me/Notes/Garden/Attachments/seedlings.png",
        "/Users/me/Notes/Garden/.obsidian/workspace.md"
    ])
    func pathOutside(_ file: String) {
        #expect(OpenNoteUseCase.path(of: URL(filePath: file), in: garden) == nil)
    }

    @Test("prefers the asking window when its Pack holds the file")
    func prefersWindow() {
        let file = URL(filePath: "/Users/me/Notes/Garden/Work/Plan.md")
        let location = OpenNoteUseCase.locate(file, roots: [left: garden, right: work], preferring: left)
        #expect(location == NoteLocation(window: left, path: NotePath("Work/Plan.md")))
    }

    @Test("otherwise picks the window whose Pack is closest to the file")
    func closestPack() {
        let file = URL(filePath: "/Users/me/Notes/Garden/Work/Plan.md")
        let location = OpenNoteUseCase.locate(file, roots: [left: garden, right: work], preferring: UUID())
        #expect(location == NoteLocation(window: right, path: NotePath("Plan.md")))
    }

    @Test("no open Pack holds the file")
    func nowhere() {
        #expect(OpenNoteUseCase.locate(URL(filePath: "/tmp/Loose.md"), roots: [left: garden], preferring: left) == nil)
    }
}
