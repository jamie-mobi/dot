//
//  WindowRegistryTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("WindowRegistry", .tags(.service))
@MainActor
struct WindowRegistryTests {
    // MARK: - Fixtures

    @MainActor
    private final class Fixture {
        let defaults: UserDefaults
        let suite = "DotWindowTests-\(UUID().uuidString)"
        let indexFolder = FileManager().temporaryDirectory.appending(component: "DotWindowIndexes-\(UUID().uuidString)")
        let windows = StubWindowListStore()
        let settings = SettingsService(store: StubSettingsStore(), clock: ServiceHarness.clock)

        init() {
            defaults = UserDefaults(suiteName: suite) ?? .standard
        }

        func registry(restoresWindows: Bool = true) -> WindowRegistry {
            WindowRegistry(store: windows, restoresWindows: restoresWindows) { [self] id, isFirst in
                let pack = PackService(
                    access: StubPackAccess(),
                    locations: UserDefaultsPackLocationStore(defaults: defaults, windowID: id, fallsBackToLastPack: isFirst),
                    launchPackURL: nil
                ) { FileSystemPackStore(rootURL: $0) }
                return ServiceGraph(
                    pack: pack,
                    makeIndex: { [indexFolder] root throws(IndexError) in
                        try GRDBIndexStore(folderURL: IndexLocation.folder(forPackAt: root, in: indexFolder))
                    },
                    recents: StubRecentNotesStore(),
                    starred: StubStarredNotesStore(),
                    folderColours: StubFolderColourStore(),
                    windowID: id,
                    windows: windows,
                    settings: settings,
                    clock: ServiceHarness.clock,
                    tagSuggester: StubTagSuggester(),
                    saveDelay: .seconds(3600)
                )
            }
        }

        func remove() {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager().removeItem(at: indexFolder)
        }
    }

    // MARK: - Tests

    @Test("the active window follows the last window activated, and moves on when it closes")
    func activeWindow() async throws {
        let fixture = Fixture()
        defer { fixture.remove() }
        let registry = fixture.registry()
        let firstID = UUID()
        let secondID = UUID()
        _ = registry.graph(for: firstID)
        let second = registry.graph(for: secondID)

        #expect(registry.activeWindowID == nil)
        registry.activate(UUID())
        #expect(registry.activeWindowID == nil)

        registry.activate(firstID)
        registry.activate(secondID)
        #expect(registry.activeWindowID == secondID)
        #expect(registry.activeGraph === second)

        await registry.close(secondID)
        #expect(registry.activeWindowID == firstID)
    }

    @Test("finds the window whose Pack holds a Note file")
    func noteLocation() async throws {
        let garden = try FixturePack()
        let fixture = Fixture()
        defer { garden.remove(); fixture.remove() }
        let registry = fixture.registry()
        let id = UUID()
        let graph = registry.graph(for: id)
        await graph.pack.open(folderURL: garden.rootURL)

        let file = garden.rootURL.appending(path: "Reading/The Soil Book.md")
        #expect(registry.location(of: file, preferring: UUID()) == NoteLocation(window: id, path: NotePath("Reading/The Soil Book.md")))
        #expect(registry.location(of: URL(filePath: "/tmp/Loose.md"), preferring: id) == nil)
    }

    @Test("two windows on two Packs share no Notes, Links, tabs or history")
    func windowsAreSeparate() async throws {
        let garden = try FixturePack()
        let empty = try FixturePack.empty()
        let fixture = Fixture()
        defer { garden.remove(); empty.remove(); fixture.remove() }
        let registry = fixture.registry()
        let first = registry.graph(for: UUID())
        let second = registry.graph(for: UUID())

        await first.pack.open(folderURL: garden.rootURL)
        await second.pack.open(folderURL: empty.rootURL)
        await first.syncFollowers()
        await second.syncFollowers()
        await first.navigation.open(NotePath("Soil.md"))
        first.notes.edit("# Soil\n\nLoam.\n")

        #expect(second.notes.path == nil)
        #expect(second.navigation.tabs.paths.isEmpty)
        #expect(second.navigation.history.canGoBack == false)
        #expect(first.links.map.backlinks(to: NotePath("Soil.md")).isEmpty == false)
        #expect(second.links.map.backlinks(to: NotePath("Soil.md")).isEmpty)
        #expect(second.pack.kind(of: NotePath("Soil.md")) == nil)
        await first.notes.flush()
        #expect(try garden.text("Soil.md") == "# Soil\n\nLoam.\n")
    }

    @Test("a Pack already open in a window brings that window to the front")
    func oneWindowPerPack() async throws {
        let garden = try FixturePack()
        let fixture = Fixture()
        defer { garden.remove(); fixture.remove() }
        let registry = fixture.registry()
        let firstID = UUID()
        let secondID = UUID()
        await registry.graph(for: firstID).pack.open(folderURL: garden.rootURL)
        _ = registry.graph(for: secondID)

        #expect(registry.decide(opening: garden.rootURL, from: secondID) == .bringToFront(firstID))
        #expect(registry.decide(opening: garden.rootURL.appending(path: "Areas/.."), from: secondID) == .bringToFront(firstID))
        #expect(registry.decide(opening: garden.rootURL, from: firstID) == .openHere)
        #expect(registry.window(showing: garden.rootURL) == firstID)
    }

    @Test("once a Pack opens, the other windows still showing Welcome are the ones to close")
    func welcomeWindowsClose() async throws {
        let garden = try FixturePack()
        let empty = try FixturePack.empty()
        let fixture = Fixture()
        defer { garden.remove(); empty.remove(); fixture.remove() }
        let registry = fixture.registry()
        let opened = UUID()
        let welcome = UUID()
        let other = UUID()
        _ = registry.graph(for: welcome)
        await registry.graph(for: other).pack.open(folderURL: empty.rootURL)
        let waiting = registry.newWindow(opening: WaitingPack(folderURL: garden.rootURL, isNew: false))
        _ = registry.graph(for: waiting)

        await registry.graph(for: opened).pack.open(folderURL: garden.rootURL)

        #expect(registry.welcomeWindows(besides: opened) == [welcome])
        #expect(registry.welcomeWindows(besides: welcome).isEmpty)
    }

    @Test("Open Pack opens here in an empty window and in a new window otherwise")
    func decidesWhereToOpen() {
        let window = UUID()
        let other = URL(filePath: "/Packs/Work")
        #expect(OpenPackUseCase.decide(opening: other, from: window, roots: [:]) == .openHere)
        #expect(OpenPackUseCase.decide(opening: other, from: window, roots: [window: URL(filePath: "/Packs/Garden")]) == .openInNewWindow)
    }

    @Test("windows and their Packs come back at the next launch")
    func restores() async throws {
        let garden = try FixturePack()
        let empty = try FixturePack.empty()
        let fixture = Fixture()
        defer { garden.remove(); empty.remove(); fixture.remove() }
        let firstID = UUID()
        let secondID = UUID()
        let before = fixture.registry()
        await before.graph(for: firstID).pack.open(folderURL: garden.rootURL)
        await before.graph(for: secondID).pack.open(folderURL: empty.rootURL)
        before.isQuitting = true
        await before.close(firstID)
        await before.close(secondID)

        let after = fixture.registry()
        #expect(after.restoredIDs == [firstID, secondID])
        #expect(after.firstWindowID == firstID)
        await after.graph(for: firstID).pack.start()
        await after.graph(for: secondID).pack.start()
        #expect(after.window(showing: garden.rootURL) == firstID)
        #expect(after.window(showing: empty.rootURL) == secondID)
    }

    @Test("closing a window saves its Notes and forgets it")
    func closes() async throws {
        let garden = try FixturePack()
        let fixture = Fixture()
        defer { garden.remove(); fixture.remove() }
        let registry = fixture.registry()
        let id = UUID()
        let graph = registry.graph(for: id)
        await graph.pack.open(folderURL: garden.rootURL)
        await graph.navigation.open(NotePath("Soil.md"))
        graph.notes.edit("# Soil\n\nClosed.\n")

        await registry.close(id)

        #expect(try garden.text("Soil.md") == "# Soil\n\nClosed.\n")
        #expect(registry.windowIDs.isEmpty)
        #expect(fixture.windows.windowIDs().isEmpty)
        #expect(fixture.windows.windowState(for: id) == nil)
        #expect(graph.pack.isOpen == false)
        #expect(fixture.settings.activePack == nil)
    }

    @Test("each window's panes, focus, split share and frame come back, without Notes that are gone")
    func restoresWindowState() async throws {
        let garden = try FixturePack()
        let empty = try FixturePack.empty()
        let fixture = Fixture()
        defer { garden.remove(); empty.remove(); fixture.remove() }
        let firstID = UUID()
        let secondID = UUID()
        let firstFrame = WindowFrame(x: 40, y: 60, width: 900, height: 700)
        let secondFrame = WindowFrame(x: 500, y: 80, width: 800, height: 600)
        let before = fixture.registry()
        let first = before.graph(for: firstID)
        await first.pack.open(folderURL: garden.rootURL)
        await first.syncFollowers()
        await first.navigation.open(NotePath("Welcome.md"))
        await first.navigation.openInNewTab(NotePath("Tomatoes.md"))
        await first.navigation.splitRight()
        await first.navigation.open(NotePath("Soil.md"))
        first.navigation.setSplitShare(0.65)
        await first.navigation.focusPane(0)
        before.setFrame(firstFrame, for: firstID)
        await before.graph(for: secondID).pack.open(folderURL: empty.rootURL)
        before.setFrame(secondFrame, for: secondID)
        before.isQuitting = true
        await before.close(firstID)
        await before.close(secondID)
        try FileManager().removeItem(at: garden.rootURL.appending(path: "Soil.md"))

        let after = fixture.registry()
        let restored = after.graph(for: firstID)
        await restored.pack.start()
        await restored.navigation.restoreWindowState()
        #expect(restored.navigation.panes.paths == [[NotePath("Welcome.md"), NotePath("Tomatoes.md")], []])
        #expect(restored.navigation.panes.focusedIndex == 0)
        #expect(restored.navigation.panes.splitShare == 0.65)
        #expect(after.savedFrame(for: firstID) == firstFrame)
        #expect(after.savedFrame(for: secondID) == secondFrame)
        let other = after.graph(for: secondID)
        await other.pack.start()
        await other.navigation.restoreWindowState()
        #expect(other.navigation.panes.isSplit == false)
        #expect(other.navigation.panes.paths == [[]])
    }

    // MARK: - Reopen at launch

    @Test("with Reopen Packs off, launch restores nothing and keeps the saved windows for later")
    func reopenOff() async {
        let fixture = Fixture()
        let saved = UUID()
        fixture.windows.setWindowIDs([saved])
        fixture.windows.setWindowState(WindowState(), for: saved)

        let registry = fixture.registry(restoresWindows: false)
        #expect(registry.restoredIDs.isEmpty)
        let id = registry.firstWindowID
        #expect(id != saved)

        _ = registry.graph(for: id)
        #expect(fixture.windows.windowIDs() == [saved])
        fixture.windows.updateWindowState(for: id) { $0.splitShare = 0.7 }

        registry.isQuitting = true
        await registry.flushAll()
        #expect(fixture.windows.windowState(for: id) == nil)
        #expect(fixture.windows.windowState(for: saved) != nil)

        #expect(fixture.registry(restoresWindows: true).restoredIDs == [saved])
    }

    @Test("with Reopen Packs off, the first window does not fall back to the last Pack")
    func reopenOffNoFallback() {
        let defaults = UserDefaults(suiteName: "DotReopenTests-\(UUID().uuidString)") ?? .standard
        defaults.set(Data([1]), forKey: "lastPackBookmark")

        #expect(UserDefaultsPackLocationStore(defaults: defaults, windowID: UUID(), fallsBackToLastPack: true).lastPackBookmark() == Data([1]))
        #expect(UserDefaultsPackLocationStore(defaults: defaults, windowID: UUID(), fallsBackToLastPack: false).lastPackBookmark() == nil)
    }

    @Test("Reopen Packs is on when older settings have no value")
    func reopenDefault() throws {
        let older = try JSONDecoder().decode(DotSettings.self, from: Data(#"{"dailyFolder":"Journal"}"#.utf8))
        #expect(older.reopensPacksAtLaunch)

        var settings = DotSettings()
        settings.reopensPacksAtLaunch = false
        #expect(try JSONDecoder().decode(DotSettings.self, from: JSONEncoder().encode(settings)).reopensPacksAtLaunch == false)
    }
}
