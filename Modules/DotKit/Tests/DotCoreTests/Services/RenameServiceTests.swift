//
//  RenameServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("RenameService", .tags(.service))
@MainActor
struct RenameServiceTests {
    // MARK: - Helpers

    private static func setUp(_ pack: FixturePack) async -> (ServiceHarness, RenameService) {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return (harness, harness.graph.renames)
    }

    // MARK: - Tests

    @Test("renaming a Note updates every Link to it and nothing else")
    func renamesAndUpdates() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (harness, service) = await Self.setUp(pack)
        let basicsBefore = try pack.text("Gardening Basics.md")
        await harness.navigation.open(NotePath("Soil.md"))

        let plan = try service.plan(renaming: NotePath("Soil.md"), to: "Earth").get()
        #expect(plan.linkingNotes == [NotePath("Areas/Health.md"), NotePath("Gardening Basics.md"), NotePath("Reading/The Soil Book.md"), NotePath("Tomatoes.md")])

        let renamed = try await service.perform(plan, from: NotePath("Soil.md"), updatingLinks: true)

        #expect(renamed == NotePath("Earth.md"))
        #expect(FileManager().fileExists(atPath: pack.url("Soil.md").path) == false)
        #expect(try pack.text("Tomatoes.md").contains("[[Earth|rich earth]]"))
        #expect(try pack.text("Tomatoes.md").contains("[[Earth#^compost-rule]]"))
        #expect(try pack.text("Areas/Health.md").contains("[soil](Earth.md)"))
        #expect(try pack.text("Gardening Basics.md") == basicsBefore.replacingOccurrences(of: "[[Soil]]", with: "[[Earth]]"))
        #expect(harness.notes.path == NotePath("Earth.md"))
        #expect(harness.pack.kind(of: NotePath("Earth.md")) == .note)
    }

    @Test("Don't Update renames only the file")
    func renamesOnly() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (_, service) = await Self.setUp(pack)
        let tomatoes = try pack.text("Tomatoes.md")

        let plan = try service.plan(renaming: NotePath("Soil.md"), to: "Earth").get()
        try await service.perform(plan, from: NotePath("Soil.md"), updatingLinks: false)

        #expect(try pack.text("Tomatoes.md") == tomatoes)
        #expect(FileManager().fileExists(atPath: pack.url("Earth.md").path))
    }

    @Test("a change of case renames the file")
    func caseOnly() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (harness, service) = await Self.setUp(pack)

        let plan = try service.plan(renaming: NotePath("Soil.md"), to: "soil").get()
        try await service.perform(plan, from: NotePath("Soil.md"), updatingLinks: true)

        #expect(try FileManager().contentsOfDirectory(atPath: pack.rootURL.path).contains("soil.md"))
        #expect(harness.pack.kind(of: NotePath("soil.md")) == .note)
    }

    @Test("renaming a Folder moves everything in it and updates Links by path only")
    func renamesFolder() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (harness, service) = await Self.setUp(pack)
        await harness.navigation.open(NotePath("Projects/Dot/Dot Roadmap.md"))

        let plan = try service.plan(renaming: NotePath("Projects"), to: "Work").get()
        #expect(plan.moves[NotePath("Projects/Dot/Dot Roadmap.md")] == NotePath("Work/Dot/Dot Roadmap.md"))
        try await service.perform(plan, from: NotePath("Projects"), updatingLinks: true)

        #expect(try pack.text("Welcome.md").contains("[[Work/Dot/Dot Roadmap|roadmap]]"))
        #expect(harness.pack.kind(of: NotePath("Work/Dot/Dot Roadmap.md")) == .note)
        #expect(harness.pack.kind(of: NotePath("Projects")) == nil)
        #expect(harness.notes.path == NotePath("Work/Dot/Dot Roadmap.md"))
    }

    @Test("moving a Note into a Folder updates path Links and keeps name Links")
    func moves() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (harness, service) = await Self.setUp(pack)

        let plan = try service.plan(moving: NotePath("Soil.md"), into: NotePath("Areas")).get()
        try await service.perform(plan, from: NotePath("Soil.md"), updatingLinks: true)

        #expect(harness.pack.kind(of: NotePath("Areas/Soil.md")) == .note)
        #expect(try pack.text("Tomatoes.md").contains("[[Soil|rich earth]]"))
        #expect(try pack.text("Areas/Health.md").contains("[soil](Soil.md)"))
    }

    @Test("deleting moves a Note to the Trash, closes it, and leaves Links to it Unresolved")
    func trashes() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let trash = FileManager().temporaryDirectory.appending(component: "DotTrash-\(UUID().uuidString)")
        defer { try? FileManager().removeItem(at: trash) }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL, trashFolderURL: trash))
        await harness.openPackWithLinks()
        let service = harness.graph.renames
        let tomatoes = try pack.text("Tomatoes.md")
        await harness.navigation.open(NotePath("Soil.md"))

        try await service.trash(NotePath("Soil.md"))

        #expect(FileManager().fileExists(atPath: pack.url("Soil.md").path) == false)
        #expect(try FileManager().contentsOfDirectory(atPath: trash.path).contains { $0.hasSuffix("Soil.md") })
        #expect(harness.notes.path == nil)
        #expect(harness.pack.kind(of: NotePath("Soil.md")) == nil)
        #expect(try pack.text("Tomatoes.md") == tomatoes)
        #expect(service.notesInside(NotePath("Projects")) == 2)
    }
}
