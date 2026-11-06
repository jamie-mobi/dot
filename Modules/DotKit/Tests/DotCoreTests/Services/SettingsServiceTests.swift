//
//  SettingsServiceTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("SettingsService", .tags(.service))
@MainActor
struct SettingsServiceTests {
    // MARK: - Helpers

    private static func setUp(_ pack: FixturePack, store: StubSettingsStore) async -> (ServiceHarness, SettingsService) {
        let harness = ServiceHarness(store: FileSystemPackStore(rootURL: pack.rootURL), settingsStore: store)
        await harness.openPack()
        return (harness, harness.graph.settings)
    }

    private static var mine: DotSettings {
        var settings = DotSettings.defaults
        settings.newFileLocation = .current
        settings.attachmentFolderPath = "Files"
        settings.useMarkdownLinks = true
        settings.linkUpdate = .never
        settings.dailyFolder = "Journal"
        settings.dailyFormat = "DD-MM-YYYY"
        return settings
    }

    // MARK: - Tests

    @Test("the Pack's Obsidian settings win where they set a value, and Dot's apply everywhere else")
    func packWins() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (harness, _) = await Self.setUp(pack, store: StubSettingsStore(Self.mine))

        #expect(harness.pack.appSettings.newFileLocation == .folder)
        #expect(harness.pack.appSettings.attachmentFolderPath == "Attachments")
        #expect(harness.pack.appSettings.useMarkdownLinks == false)
        #expect(harness.pack.dailyNoteSettings == DailyNoteSettings(folder: "Daily Notes", format: "YYYY-MM-DD", template: "Templates/Daily"))
        #expect(harness.pack.linkUpdate == .never)
        #expect(harness.pack.packSettings.attachmentFolderPath == "Attachments")
        #expect(harness.pack.packSettings.alwaysUpdateLinks == nil)
    }

    @Test("without Obsidian settings in the Pack, Dot's settings apply")
    func dotApplies() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        try FileManager().removeItem(at: pack.url(".obsidian"))
        let (harness, _) = await Self.setUp(pack, store: StubSettingsStore(Self.mine))

        #expect(harness.pack.appSettings.newFileLocation == .current)
        #expect(harness.pack.appSettings.attachmentFolderPath == "Files")
        #expect(harness.pack.appSettings.useMarkdownLinks == true)
        #expect(harness.pack.dailyNoteSettings == DailyNoteSettings(folder: "Journal", format: "DD-MM-YYYY", template: ""))
    }

    @Test("alwaysUpdateLinks in the Pack means Always, and false means Ask")
    func alwaysUpdateLinks() {
        #expect(SettingsUseCase.linkUpdate(.defaults, pack: PackSettings(alwaysUpdateLinks: true)) == .always)
        #expect(SettingsUseCase.linkUpdate(Self.mine, pack: PackSettings(alwaysUpdateLinks: false)) == .ask)
    }

    @Test("changing a setting saves it in Dot's preferences and writes nothing in the Pack")
    func savesOutsidePack() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let before = try FileManager().subpathsOfDirectory(atPath: pack.rootURL.path).sorted()
        let appJSON = try pack.text(".obsidian/app.json")
        let store = StubSettingsStore()
        let (_, service) = await Self.setUp(pack, store: store)

        service.settings.linkUpdate = .always
        service.settings.dailyFormat = "YYYY/MM/DD"

        #expect(store.saved?.linkUpdate == .always)
        #expect(store.saved?.dailyFormat == "YYYY/MM/DD")
        #expect(try FileManager().subpathsOfDirectory(atPath: pack.rootURL.path).sorted() == before)
        #expect(try pack.text(".obsidian/app.json") == appJSON)
    }

    @Test("settings saved before keep their values, and missing keys take the defaults")
    func decodesOldSettings() throws {
        let decoded = try JSONDecoder().decode(DotSettings.self, from: Data(#"{"linkUpdate":"never"}"#.utf8))
        #expect(decoded.linkUpdate == .never)
        #expect(decoded.dailyFormat == "YYYY-MM-DD")
    }

    @Test("the Daily Note preview formats today with the clock")
    func preview() async throws {
        let pack = try FixturePack()
        defer { pack.remove() }
        let (_, service) = await Self.setUp(pack, store: StubSettingsStore())

        #expect(service.dailyNotePreview(format: "YYYY-MM-DD") == "2026-10-26")
        #expect(service.dailyNotePreview(format: "") == "2026-10-26")
    }

    @Test("one change reaches every attached Pack, and the active Pack's Obsidian settings are shown")
    func reachesEveryPack() {
        let service = SettingsService(store: StubSettingsStore(), clock: ServiceHarness.clock)
        let first = ServiceHarness(store: StubPackFileStore()).pack
        let second = ServiceHarness(store: StubPackFileStore()).pack
        service.attach(first)
        service.attach(second)

        service.settings.linkUpdate = .never

        #expect(first.linkUpdate == .never)
        #expect(second.linkUpdate == .never)
        #expect(service.activePack === second)
        service.activate(first)
        #expect(service.activePack === first)
        service.detach(first)
        #expect(service.activePack === second)
    }
}
