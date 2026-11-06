//
//  PackHomeUseCaseTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("PackHomeUseCase", .tags(.domain))
struct PackHomeUseCaseTests {
    // MARK: - Helpers

    private func stamps(_ ages: [String: TimeInterval]) -> [NotePath: FileStamp] {
        Dictionary(uniqueKeysWithValues: ages.map { (NotePath($0.key), FileStamp(modified: Date(timeIntervalSinceReferenceDate: 1_000_000 - $0.value), size: 1)) })
    }

    // MARK: - Tests

    @Test("Recently edited lists the newest Notes first, up to the limit")
    func recent() {
        let layout = PackHomeUseCase.layout(stamps: stamps(["A.md": 30, "B.md": 10, "Projects/C.md": 20]), recentCount: 2)
        #expect(layout.recent == [NotePath("B.md"), NotePath("Projects/C.md")])
        #expect(layout.noteCount == 3)
    }

    @Test("each top Folder is a group, newest group first, with its count and newest Notes")
    func groups() {
        let layout = PackHomeUseCase.layout(
            stamps: stamps(["Daily/1.md": 5, "Daily/2.md": 6, "Daily/3.md": 7, "Daily/Old/4.md": 8, "Areas/H.md": 1, "Root.md": 0]),
            notesPerGroup: 2
        )
        #expect(layout.groups == [
            PackHomeGroup(folder: NotePath("Areas"), noteCount: 1, notes: [NotePath("Areas/H.md")]),
            PackHomeGroup(folder: NotePath("Daily"), noteCount: 4, notes: [NotePath("Daily/1.md"), NotePath("Daily/2.md")])
        ])
    }

    @Test("only the most recently edited Folders get a group")
    func groupLimit() {
        let layout = PackHomeUseCase.layout(stamps: stamps(["A/1.md": 1, "B/1.md": 2, "C/1.md": 3]), groupLimit: 2)
        #expect(layout.groups.map(\.folder) == [NotePath("A"), NotePath("B")])
    }

    @Test("a Note shown twice is read once")
    func shownOnce() {
        let layout = PackHomeUseCase.layout(stamps: stamps(["Areas/H.md": 1]))
        #expect(layout.shownNotes == [NotePath("Areas/H.md")])
    }

    @Test("an empty Pack has an empty home")
    func empty() {
        #expect(PackHomeUseCase.layout(stamps: [:]) == .empty)
    }
}
