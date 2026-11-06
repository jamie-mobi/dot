//
//  QuickSwitcherServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("QuickSwitcherService with a fixture Pack", .tags(.service))
@MainActor
struct QuickSwitcherServiceTests {
    // MARK: - Helpers

    private static func harness(_ pack: FixturePack) async -> ServiceHarness {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPackWithLinks()
        return harness
    }

    // MARK: - Tests

    @Test("Headings come from the target Note, or the open Note with unsaved edits, and none for an Unresolved target")
    func headingSuggestions() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)
        let source = NotePath("Welcome.md")

        let target = await harness.switcher.linkSuggestions(for: LinkQuery(bracketLocation: 0, queryLocation: 0, text: "wat", scope: .headings(of: "Gardening Basics")), from: source)
        #expect(target == [.heading(NotePath("Gardening Basics.md"), text: "Watering", level: 2)])

        let missing = await harness.switcher.linkSuggestions(for: LinkQuery(bracketLocation: 0, queryLocation: 0, text: "", scope: .headings(of: "No Such Note")), from: source)
        #expect(missing.isEmpty)

        harness.links.showNotes([source], focused: source)
        harness.links.noteChanged(source, text: "# Unsaved Heading\n")
        await harness.links.waitForOpenNote()
        let own = await harness.switcher.linkSuggestions(for: LinkQuery(bracketLocation: 0, queryLocation: 0, text: "", scope: .headings(of: "")), from: source)
        #expect(own == [.heading(nil, text: "Unsaved Heading", level: 1)])
    }

    @Test("finds Soil by its Alias and opens it")
    func aliasOpens() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        await harness.switcher.prepare(query: "dirt")
        #expect(harness.switcher.selected?.matchedAlias == "Dirt")

        await harness.switcher.confirm()
        #expect(harness.notes.path == NotePath("Soil.md"))
    }

    @Test("arrow keys move the selection within the results")
    func selection() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        await harness.switcher.prepare(query: "so")
        harness.switcher.moveSelection(by: 1)
        #expect(harness.switcher.selected?.path == NotePath("Reading/The Soil Book.md"))

        harness.switcher.moveSelection(by: -5)
        #expect(harness.switcher.selectedIndex == 0)
    }

    @Test("with no match, confirming creates the Note where new Notes go")
    func creates() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        await harness.switcher.prepare(query: "Zucchini")
        #expect(harness.switcher.canCreate)

        let created = await harness.switcher.confirm()
        #expect(created == NotePath("Inbox/Zucchini.md"))
        #expect(FileManager().fileExists(atPath: pack.url("Inbox/Zucchini.md").path))
        #expect(harness.notes.path == created)
    }

    @Test("an empty query lists the Notes opened last first, and remembers them outside the Pack")
    func recent() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = await Self.harness(pack)

        await harness.navigation.open(NotePath("Tomatoes.md"))
        await harness.navigation.open(NotePath("Areas/Health.md"))
        await harness.switcher.prepare()

        #expect(harness.switcher.results.prefix(2).map(\.path) == [NotePath("Areas/Health.md"), NotePath("Tomatoes.md")])
        #expect(await harness.recents.recentNotes(forPackAt: harness.store.rootURL).first == NotePath("Areas/Health.md"))
    }

    @Test("with newFileLocation current, a created Note goes in the open Note's Folder")
    func createsBesideOpenNote() async {
        let store = StubPackFileStore(
            files: ["Soil.md": "# Soil\n", "Areas/Health.md": "# Health\n"],
            folders: ["Areas"],
            settingsJSON: #"{"newFileLocation":"current"}"#
        )
        let harness = ServiceHarness(store: store)
        await harness.openPackWithLinks()
        await harness.navigation.open(NotePath("Areas/Health.md"))

        await harness.switcher.prepare(query: "Zucchini")
        let created = await harness.switcher.confirm()

        #expect(created == NotePath("Areas/Zucchini.md"))
        #expect(await store.text("Areas/Zucchini.md") == "")
    }

    @Test("tabs open, close and come back for the same Pack")
    func tabs() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()

        await harness.navigation.open(NotePath("Welcome.md"))
        await harness.navigation.openInNewTab(NotePath("Soil.md"))
        #expect(harness.notes.path == NotePath("Soil.md"))
        #expect(harness.navigation.tabs.paths == [NotePath("Welcome.md"), NotePath("Soil.md")])

        await harness.navigation.selectTab(harness.navigation.tabs.tabs[0].id)
        #expect(harness.notes.path == NotePath("Welcome.md"))

        let restored = NavigationService(pack: harness.pack, notes: harness.notes, links: harness.links, recents: harness.recents, windowID: harness.windowID, windows: harness.windows)
        await restored.restoreWindowState()
        #expect(restored.tabs.paths == [NotePath("Welcome.md"), NotePath("Soil.md")])

        await harness.navigation.closeSelectedTab()
        #expect(harness.notes.path == NotePath("Soil.md"))
    }
}
