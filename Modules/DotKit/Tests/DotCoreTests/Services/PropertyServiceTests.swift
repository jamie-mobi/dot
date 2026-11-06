//
//  PropertyServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("NoteService Properties", .tags(.service))
@MainActor
struct PropertyServiceTests {
    @Test("editing a Property in the form writes only its lines")
    func editWritesOnlyItsLines() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        let path = NotePath("Welcome.md")
        let before = try pack.text(path.rawValue)
        await harness.navigation.open(path)
        await harness.links.waitForOpenNote()

        let created = try #require(harness.notes.frontmatter?.properties.first { $0.key == "created" })
        harness.notes.setProperty(created, to: .text("2026-02-01"))
        await harness.notes.flush()

        #expect(try pack.text(path.rawValue) == before.replacingOccurrences(of: "created: 2026-01-04", with: "created: 2026-02-01"))
    }

    @Test("the Properties stay while typing, before the analysis catches up")
    func frontmatterSurvivesTyping() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        let path = NotePath("Welcome.md")
        await harness.navigation.open(path)
        await harness.links.waitForOpenNote()

        harness.notes.edit(try pack.text(path.rawValue) + "x")

        #expect(harness.notes.frontmatter?.properties.contains { $0.key == "created" } == true)
    }

    @Test("types come from .obsidian/types.json when it is there")
    func declaredTypes() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let folder = pack.url(".obsidian")
        try FileManager().createDirectory(at: folder, withIntermediateDirectories: true)
        try Data(#"{"types":{"created":"text","rating":"number","odd":"unknown"}}"#.utf8).write(to: folder.appending(path: "types.json"))
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Welcome.md"))
        await harness.links.waitForOpenNote()

        #expect(harness.pack.propertyTypes == ["created": .text, "rating": .number])
        let created = try #require(harness.notes.frontmatter?.properties.first { $0.key == "created" })
        #expect(harness.notes.type(of: created) == .text)
    }

    @Test("adding a Property appends it to the frontmatter")
    func add() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Welcome.md"))
        await harness.links.waitForOpenNote()

        harness.notes.addProperty(named: "status")
        harness.notes.addProperty(named: "status")
        await harness.links.waitForOpenNote()

        #expect(harness.notes.frontmatter?.properties.map(\.key) == ["aliases", "tags", "created", "status"])
    }

    @Test("a Property takes its type from the Pack, and from its own value until the Index is ready")
    func packWideType() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        for (index, rating) in ["4", "5", "3"].enumerated() {
            try pack.write("---\nrating: \(rating)\n---\n", to: "Rated \(index).md")
        }
        try pack.write("---\nrating: high\n---\n", to: "Odd.md")
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Odd.md"))
        await harness.links.waitForOpenNote()
        let document = try #require(harness.notes.focused)
        let rating = try #require(harness.notes.frontmatter?.properties.first { $0.key == "rating" })

        await document.refreshPropertyTypes()
        #expect(document.type(of: rating) == .text)

        await harness.index.sync()
        await document.refreshPropertyTypes()
        #expect(document.type(of: rating) == .number)
        #expect(harness.notes.type(of: rating) == .number)
    }

    @Test("types.json still wins over the Pack-wide type")
    func declaredBeatsPackWide() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let folder = pack.url(".obsidian")
        try FileManager().createDirectory(at: folder, withIntermediateDirectories: true)
        try Data(#"{"types":{"rating":"text"}}"#.utf8).write(to: folder.appending(path: "types.json"))
        for index in 0 ..< 3 {
            try pack.write("---\nrating: \(index)\n---\n", to: "Rated \(index).md")
        }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.navigation.open(NotePath("Rated 0.md"))
        await harness.links.waitForOpenNote()
        await harness.index.sync()
        let document = try #require(harness.notes.focused)
        let rating = try #require(harness.notes.frontmatter?.properties.first { $0.key == "rating" })

        await document.refreshPropertyTypes()

        #expect(document.type(of: rating) == .text)
    }

    @Test("when the Index changes, the form's types follow")
    func typesFollowTheIndex() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        try pack.write("---\nrating: 4\n---\n", to: "Mine.md")
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()
        await harness.index.sync()
        await harness.navigation.open(NotePath("Mine.md"))
        await harness.links.waitForOpenNote()
        let document = try #require(harness.notes.focused)
        let rating = try #require(harness.notes.frontmatter?.properties.first { $0.key == "rating" })
        await document.refreshPropertyTypes()
        #expect(document.type(of: rating) == .number)

        var paths: Set<NotePath> = []
        for index in 0 ..< 3 {
            try pack.write("---\nrating: low\n---\n", to: "Text \(index).md")
            paths.insert(NotePath("Text \(index).md"))
        }
        await harness.index.update(paths)
        await document.refreshPropertyTypes()

        #expect(document.type(of: rating) == .text)
    }
}
