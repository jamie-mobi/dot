//
//  UserDefaultsPackLocationStoreTests.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import Testing
@testable import DotCore

@Suite("UserDefaultsPackLocationStore", .tags(.data))
struct UserDefaultsPackLocationStoreTests {
    // MARK: - Tests

    @Test("moves bookmarks and recent Packs saved under the old key names")
    func migratesLegacyKeys() throws {
        let suite = "DotPackLocationStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let windowID = UUID()
        let records = [RecentPackRecord(bookmark: Data([1]), path: "/Packs/Garden")]
        defaults.set(Data([7]), forKey: "lastVaultBookmark")
        defaults.set(Data([8]), forKey: "lastVaultBookmark." + windowID.uuidString)
        defaults.set(try JSONEncoder().encode(records), forKey: "recentVaults")

        let store = UserDefaultsPackLocationStore(defaults: defaults, windowID: windowID, fallsBackToLastPack: true)

        #expect(store.lastPackBookmark() == Data([8]))
        #expect(UserDefaultsPackLocationStore(defaults: defaults).lastPackBookmark() == Data([7]))
        #expect(store.recentPacks() == records)
        #expect(defaults.object(forKey: "lastVaultBookmark") == nil)
        #expect(defaults.object(forKey: "recentVaults") == nil)
    }

    @Test("keeps a value already saved under the new key name")
    func keepsCurrentKeys() throws {
        let suite = "DotPackLocationStoreTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        defaults.set(Data([7]), forKey: "lastVaultBookmark")
        defaults.set(Data([9]), forKey: "lastPackBookmark")

        #expect(UserDefaultsPackLocationStore(defaults: defaults).lastPackBookmark() == Data([9]))
    }
}
