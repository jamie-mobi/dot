//
//  RecentPacksTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("Recent Packs", .tags(.service))
@MainActor
struct RecentPacksTests {
    // MARK: - Fixtures

    @MainActor
    private final class Fixture {
        let suite = "DotRecentPacksTests-\(UUID().uuidString)"
        let defaults: UserDefaults
        let container = FileManager().temporaryDirectory.appending(component: "DotRecentPacks-\(UUID().uuidString)")

        init() throws {
            defaults = try #require(UserDefaults(suiteName: suite))
            try FileManager().createDirectory(at: container, withIntermediateDirectories: true)
        }

        func service(access: StubPackAccess = StubPackAccess()) -> RecentPacksService {
            RecentPacksService(access: access, locations: UserDefaultsPackLocationStore(defaults: defaults))
        }

        func folder(_ name: String) throws -> URL {
            let url = container.appending(component: name, directoryHint: .isDirectory)
            try FileManager().createDirectory(at: url, withIntermediateDirectories: true)
            return url
        }

        func remove() {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager().removeItem(at: container)
        }
    }

    // MARK: - Tests

    @Test("keeps a Pack once, by resolved path, newest first, and stops at ten")
    func recording() {
        let records = (1 ... 12).map { RecentPackRecord(bookmark: Data(), path: "/Packs/V\($0)") }
        let capped = records.reduce([RecentPackRecord]()) { RecentPacksUseCase.recording($1, in: $0) }

        #expect(capped.count == RecentPacksUseCase.limit)
        #expect(capped.map(\.path).first == "/Packs/V12")
        #expect(capped.map(\.path).last == "/Packs/V3")

        let again = RecentPacksUseCase.recording(RecentPackRecord(bookmark: Data(), path: "/Packs/V5/"), in: capped)
        #expect(again.map(\.path).first == "/Packs/V5/")
        #expect(again.count == RecentPacksUseCase.limit)
        #expect(again.filter { RecentPacksUseCase.key(for: $0.path) == RecentPacksUseCase.key(for: "/Packs/V5") }.count == 1)
    }

    @Test("remembers the last ten Packs in the suite, outside the Pack, newest first")
    func remembers() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let folders = try (1 ... 12).map { try fixture.folder("V\($0)") }
        let service = fixture.service()

        for folder in folders {
            await service.record(folder)
        }
        await service.record(folders[5])

        let reopened = fixture.service()
        await reopened.load()
        #expect(reopened.packs.count == 10)
        #expect(reopened.packs.map(\.name) == ["V6", "V12", "V11", "V10", "V9", "V8", "V7", "V5", "V4", "V3"])
        #expect(reopened.packs.allSatisfy { $0.isMissing == false })
        #expect(reopened.packs.first?.parentPath == fixture.container.path(percentEncoded: false))
    }

    @Test("shows a Pack whose folder is gone as missing, and removing it leaves the others")
    func missingFolder() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let gone = try fixture.folder("Gone")
        let kept = try fixture.folder("Kept")
        let service = fixture.service()
        await service.record(gone)
        await service.record(kept)

        try FileManager().removeItem(at: gone)
        await service.load()

        let missing = try #require(service.packs.first { $0.name == "Gone" })
        #expect(missing.isMissing)
        #expect(service.packs.first { $0.name == "Kept" }?.isMissing == false)

        await service.remove(missing)
        #expect(service.packs.map(\.name) == ["Kept"])
        await service.clear()
        #expect(service.packs.isEmpty)
        #expect(fixture.service().packs.isEmpty)
    }

    @Test("a bookmark that no longer resolves is shown as missing with its last path")
    func unresolvedBookmark() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let folder = try fixture.folder("Moved")
        await fixture.service().record(folder)

        let service = fixture.service(access: StubPackAccess(resolvesBookmarks: false))
        await service.load()

        #expect(service.packs.map(\.isMissing) == [true])
        #expect(service.packs.map(\.name) == ["Moved"])
    }

    @Test("opening a Pack records it, and a Pack passed at launch is not recorded")
    func packServiceRecords() async throws {
        let fixture = try Fixture()
        defer { fixture.remove() }
        let folder = try fixture.folder("Garden")
        let recents = fixture.service()
        let access = StubPackAccess()
        let locations = UserDefaultsPackLocationStore(defaults: fixture.defaults)
        let makeStore: @Sendable (URL) -> any PackFileStoring = { FileSystemPackStore(rootURL: $0) }

        let launched = PackService(access: access, locations: locations, launchPackURL: folder, recents: recents, makeStore: makeStore)
        await launched.start()
        #expect(recents.packs.isEmpty)

        let opening = PackService(access: access, locations: locations, launchPackURL: nil, recents: recents, makeStore: makeStore)
        await opening.open(folderURL: folder)
        #expect(recents.packs.map(\.name) == ["Garden"])
    }

    @Test("choosing a Pack opens it here with no Pack, in its own window if shown, and in a new window otherwise")
    func choosing() {
        let recent = RecentPack(record: RecentPackRecord(bookmark: Data(), path: "/Packs/Garden"), folderURL: URL(filePath: "/Packs/Garden", directoryHint: .isDirectory), isMissing: false)
        let empty = UUID()
        let showing = UUID()
        let other = UUID()

        #expect(OpenPackUseCase.decide(opening: recent.folderURL, from: empty, roots: [:]) == .openHere)
        #expect(OpenPackUseCase.decide(opening: recent.folderURL, from: other, roots: [showing: recent.folderURL, other: URL(filePath: "/Packs/Other")]) == .bringToFront(showing))
        #expect(OpenPackUseCase.decide(opening: recent.folderURL, from: other, roots: [other: URL(filePath: "/Packs/Other")]) == .openInNewWindow)
        #expect(OpenPackUseCase.decide(opening: recent.folderURL, from: showing, roots: [showing: recent.folderURL]) == .openHere)
    }
}
