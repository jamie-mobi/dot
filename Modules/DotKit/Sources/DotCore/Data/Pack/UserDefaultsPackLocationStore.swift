//
//  UserDefaultsPackLocationStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public final class UserDefaultsPackLocationStore: PackLocationStoring, @unchecked Sendable {
    // MARK: - Constants

    private enum Constants {
        static let lastPackBookmarkKey = "lastPackBookmark"
        static let recentPacksKey = "recentPacks"
        static let legacyKeyPrefixes = ["lastVaultBookmark": "lastPackBookmark", "recentVaults": "recentPacks"]
    }

    // MARK: - Private

    private let defaults: UserDefaults
    private let key: String
    private let fallbackKey: String?

    // MARK: - Init

    public init(defaults: UserDefaults) {
        self.defaults = defaults
        key = Constants.lastPackBookmarkKey
        fallbackKey = nil
        Self.migrateLegacyKeys(in: defaults)
    }

    public init(defaults: UserDefaults, windowID: UUID, fallsBackToLastPack: Bool) {
        self.defaults = defaults
        key = Constants.lastPackBookmarkKey + "." + windowID.uuidString
        fallbackKey = fallsBackToLastPack ? Constants.lastPackBookmarkKey : nil
        Self.migrateLegacyKeys(in: defaults)
    }

    // MARK: - Migration

    private static func migrateLegacyKeys(in defaults: UserDefaults) {
        for (oldKey, value) in defaults.dictionaryRepresentation() {
            guard let (legacy, current) = Constants.legacyKeyPrefixes.first(where: { oldKey.hasPrefix($0.key) }) else {
                continue
            }
            let newKey = current + oldKey.dropFirst(legacy.count)
            if defaults.object(forKey: newKey) == nil {
                defaults.set(value, forKey: newKey)
            }
            defaults.removeObject(forKey: oldKey)
        }
    }

    // MARK: - PackLocationStoring

    public func lastPackBookmark() -> Data? {
        defaults.data(forKey: key) ?? fallbackKey.flatMap(defaults.data(forKey:))
    }

    public func setLastPackBookmark(_ bookmark: Data?) {
        defaults.set(bookmark, forKey: key)
    }

    public func recentPacks() -> [RecentPackRecord] {
        defaults.data(forKey: Constants.recentPacksKey).flatMap { try? JSONDecoder().decode([RecentPackRecord].self, from: $0) } ?? []
    }

    public func setRecentPacks(_ records: [RecentPackRecord]) {
        defaults.set(try? JSONEncoder().encode(records), forKey: Constants.recentPacksKey)
    }
}
