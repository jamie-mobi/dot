//
//  PackServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("PackService", .tags(.service))
struct PackServiceTests {
    @Test("is closed with no message before a Pack was ever opened")
    func initialState() async {
        let harness = await ServiceHarness(store: StubPackFileStore())

        await harness.pack.start()

        #expect(await harness.pack.loadState == .closed(nil))
    }

    @Test("opening a Pack builds its tree, reads Obsidian's settings and remembers it")
    func opens() async {
        let store = StubPackFileStore(
            files: ["Soil.md": "", "Areas/Health.md": "", ".obsidian/app.json": "{}"],
            folders: ["Areas", ".obsidian"],
            settingsJSON: #"{"newFileLocation":"folder","newFileFolderPath":"Inbox"}"#
        )
        let harness = await ServiceHarness(store: store)

        await harness.openPack()

        #expect(await harness.pack.loadState == .open(Pack(rootURL: store.rootURL)))
        #expect(await harness.pack.tree.map(\.displayName) == ["Areas", "Soil"])
        #expect(await harness.pack.appSettings.newFileLocation == .folder)
        #expect(await harness.locations.bookmark == Data(store.rootURL.path.utf8))
    }

    @Test("start reopens the remembered Pack")
    func reopensLastPack() async {
        let store = StubPackFileStore(files: ["Soil.md": ""])
        let locations = StubPackLocationStore(bookmark: Data(store.rootURL.path.utf8))
        let harness = await ServiceHarness(store: store, locations: locations)

        await harness.pack.start()
        await harness.pack.start()

        #expect(await harness.pack.loadState == .open(Pack(rootURL: store.rootURL)))
        #expect(await store.listCount == 1)
        #expect(await locations.setCount == 0)
    }

    @Test("a remembered Pack that has gone away leaves Dot closed with a reason")
    func missingPack() async {
        let locations = StubPackLocationStore(bookmark: Data("/Gone".utf8))
        let harness = await ServiceHarness(store: StubPackFileStore(), access: StubPackAccess(resolvesBookmarks: false), locations: locations)

        await harness.pack.start()

        #expect(await harness.pack.loadState == .closed(.packMissing))
    }

    @Test("a stale bookmark is replaced after the Pack opens")
    func refreshesStaleBookmark() async {
        let store = StubPackFileStore()
        let locations = StubPackLocationStore(bookmark: Data(store.rootURL.path.utf8))
        let harness = await ServiceHarness(store: store, access: StubPackAccess(resolvesStale: true), locations: locations)

        await harness.pack.start()

        #expect(await locations.setCount == 1)
    }

    @Test("a launch Pack opens without being remembered")
    func launchPack() async {
        let store = StubPackFileStore()
        let harness = await ServiceHarness(store: store, launchPackURL: store.rootURL)

        await harness.pack.start()

        #expect(await harness.pack.isOpen)
        #expect(await harness.locations.setCount == 0)
    }

    @Test("an unreadable Pack folder leaves Dot closed with a reason")
    func unreadable() async {
        let store = StubPackFileStore()
        await store.failLists(with: .folderUnreadable)
        let harness = await ServiceHarness(store: store)

        await harness.openPack()

        #expect(await harness.pack.loadState == .closed(.folderUnreadable))
        #expect(await harness.pack.store == nil)
    }

    @Test("a new Note goes to Obsidian's new Note Folder, created if missing, and appears in the tree without a reload")
    func createsNote() async throws {
        let store = StubPackFileStore(files: ["Soil.md": ""], settingsJSON: #"{"newFileLocation":"folder","newFileFolderPath":"Inbox"}"#)
        let harness = await ServiceHarness(store: store)
        await harness.openPack()

        let first = try await harness.pack.createNote(openNote: nil)
        let second = try await harness.pack.createNote(openNote: nil)

        #expect(first == NotePath("Inbox/Untitled.md"))
        #expect(second == NotePath("Inbox/Untitled 1.md"))
        #expect(await store.text("Inbox/Untitled.md") == "")
        #expect(await harness.pack.tree.first?.displayName == "Inbox")
        let inboxNames = await harness.pack.tree.first?.children?.map(\.displayName)
        #expect(inboxNames == ["Untitled", "Untitled 1"])
        #expect(await harness.pack.kind(of: NotePath("Inbox")) == .folder)
        #expect(await store.listCount == 1)
    }

    @Test("a new Folder goes inside the selected Folder")
    func createsFolder() async throws {
        let store = StubPackFileStore(folders: ["Areas"])
        let harness = await ServiceHarness(store: store)
        await harness.openPack()

        let folder = try await harness.pack.createFolder(near: NotePath("Areas"))

        #expect(folder == NotePath("Areas/Untitled"))
        #expect(await harness.pack.kind(of: folder) == .folder)
    }

    @Test("creating a Note with no Pack open fails")
    func createWithoutPack() async {
        let harness = await ServiceHarness(store: StubPackFileStore())

        await #expect(throws: PackError.noPackOpen) {
            try await harness.pack.createNote(openNote: nil)
        }
    }

    @Test("refresh reads the tree again")
    func refresh() async {
        let store = StubPackFileStore(files: ["Soil.md": ""])
        let harness = await ServiceHarness(store: store)
        await harness.openPack()

        await store.changeOnDisk("Tomatoes.md", to: "")
        await harness.pack.refresh()

        #expect(await harness.pack.tree.map(\.displayName) == ["Soil", "Tomatoes"])
    }

    @Test("duplicating a Note copies it beside the original with the next free name")
    @MainActor
    func duplicates() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL))
        await harness.openPack()

        let first = try await harness.pack.duplicate(NotePath("Areas/Health.md"))
        let second = try await harness.pack.duplicate(NotePath("Areas/Health.md"))

        #expect(first == NotePath("Areas/Health 1.md"))
        #expect(second == NotePath("Areas/Health 2.md"))
        #expect(try Data(contentsOf: pack.url("Areas/Health 1.md")) == Data(contentsOf: pack.url("Areas/Health.md")))
        #expect(harness.pack.kind(of: first) == .note)
    }
}
