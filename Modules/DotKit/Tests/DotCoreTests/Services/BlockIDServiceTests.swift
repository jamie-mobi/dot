//
//  BlockIDServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Adding a Block id from [[#^", .tags(.service))
@MainActor
struct BlockIDServiceTests {
    // MARK: - Helpers

    private static func setUp(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("[[Soil#^ lists Soil's paragraphs without an id after its Blocks")
    func suggestions() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let query = LinkQuery(bracketLocation: 0, queryLocation: 8, text: "", scope: .blocks(of: "Soil"))

        let found = await harness.switcher.linkSuggestions(for: query, from: NotePath("Tomatoes.md"))

        #expect(found == [
            .block(NotePath("Soil.md"), id: "compost-rule", text: "Compost improves every kind."),
            .newBlock(NotePath("Soil.md"), line: 8, text: "Soil is a mix of sand, silt, clay and organic matter."),
            .newBlock(NotePath("Soil.md"), line: 18, text: "Tomatoes need rich soil, as Gardening Basics says.")
        ])
    }

    @Test("nothing is written until the plan is applied, and then only that line changes")
    func planThenApply() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let before = try pack.text("Soil.md")

        let plan = try #require(await harness.graph.blockIDs.plan(addingTo: 18, in: NotePath("Soil.md")))
        #expect(try pack.text("Soil.md") == before)

        try await harness.graph.blockIDs.apply(plan)

        let after = try pack.text("Soil.md")
        #expect(after == before.replacingOccurrences(of: "as Gardening Basics says.", with: "as Gardening Basics says. ^\(plan.id)"))
        #expect(plan.id.count == BlockIDUseCase.idLength)
    }

    @Test("a Note changed after the plan is not written")
    func changedOnDisk() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        let plan = try #require(await harness.graph.blockIDs.plan(addingTo: 18, in: NotePath("Soil.md")))
        try Data("Changed elsewhere.\n".utf8).write(to: pack.url("Soil.md"))

        await #expect(throws: PackError.writeFailed(NotePath("Soil.md"))) {
            try await harness.graph.blockIDs.apply(plan)
        }
        #expect(try pack.text("Soil.md") == "Changed elsewhere.\n")
    }

    @Test("a Note open in the Editor is not offered and not planned")
    func openNote() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.setUp(pack)
        await harness.navigation.open(NotePath("Soil.md"))

        #expect(await harness.graph.blockIDs.plan(addingTo: 18, in: NotePath("Soil.md")) == nil)
    }
}
