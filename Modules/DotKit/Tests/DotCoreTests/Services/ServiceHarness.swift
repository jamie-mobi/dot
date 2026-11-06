//
//  ServiceHarness.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
@testable import DotCore

struct ServiceHarness {
    // MARK: - Constants

    static let clock = FixedClock(now: Date(timeIntervalSince1970: 1_793_000_000), timeZone: TimeZone(identifier: "Australia/Sydney") ?? .gmt)

    // MARK: - Stored

    let store: any PackFileStoring
    let graph: ServiceGraph
    let locations: StubPackLocationStore
    let pack: PackService
    let notes: NoteService
    let links: LinkService
    let navigation: NavigationService
    let switcher: QuickSwitcherService
    let recents: StubRecentNotesStore
    let starred: StubStarredNotesStore
    let folderColourStore: StubFolderColourStore
    let windowID: UUID
    let windows: StubWindowListStore
    let index: IndexService
    let search: SearchService
    let mentions: MentionService
    let indexFolder: URL
    let tagSuggester: StubTagSuggester
    let tagSuggestions: TagSuggestionService
    let settings: SettingsService

    // MARK: - Init

    @MainActor
    init(
        store: any PackFileStoring,
        access: StubPackAccess = StubPackAccess(),
        locations: StubPackLocationStore = StubPackLocationStore(),
        launchPackURL: URL? = nil,
        makeWatcher: (@Sendable (URL) -> any PackWatching)? = nil,
        settingsStore: StubSettingsStore = StubSettingsStore(),
        tagSuggester: StubTagSuggester = StubTagSuggester()
    ) {
        self.store = store
        self.locations = locations
        let pack = PackService(access: access, locations: locations, launchPackURL: launchPackURL, makeWatcher: makeWatcher) { _ in store }
        let indexFolder = FileManager().temporaryDirectory.appending(component: "DotIndexTests-\(UUID().uuidString)")
        let recents = StubRecentNotesStore()
        let starred = StubStarredNotesStore()
        let folderColourStore = StubFolderColourStore()
        let windowID = UUID()
        let windows = StubWindowListStore()
        let graph = ServiceGraph(
            pack: pack,
            makeIndex: { root throws(IndexError) in
                try GRDBIndexStore(folderURL: IndexLocation.folder(forPackAt: root, in: indexFolder))
            },
            recents: recents,
            starred: starred,
            folderColours: folderColourStore,
            windowID: windowID,
            windows: windows,
            settings: SettingsService(store: settingsStore, clock: Self.clock),
            clock: Self.clock,
            tagSuggester: tagSuggester,
            saveDelay: .seconds(3600)
        )
        self.graph = graph
        self.pack = pack
        self.indexFolder = indexFolder
        self.recents = recents
        self.starred = starred
        self.folderColourStore = folderColourStore
        self.windowID = windowID
        self.windows = windows
        index = graph.index
        links = graph.links
        notes = graph.notes
        navigation = graph.navigation
        switcher = graph.switcher
        search = graph.search
        mentions = graph.mentions
        self.tagSuggester = tagSuggester
        tagSuggestions = graph.tagSuggestions
        settings = graph.settings
    }

    // MARK: - Steps

    @MainActor
    func openPack() async {
        await pack.open(folderURL: store.rootURL)
    }

    @MainActor
    func openPackWithLinks() async {
        await openPack()
        await links.sync()
    }
}
