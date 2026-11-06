//
//  StubPackLocationStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
@testable import DotCore

actor StubPackLocationStore: PackLocationStoring {
    // MARK: - Stored

    private(set) var bookmark: Data?
    private(set) var setCount = 0
    private(set) var recents: [RecentPackRecord] = []

    // MARK: - Init

    init(bookmark: Data? = nil) {
        self.bookmark = bookmark
    }

    // MARK: - PackLocationStoring

    func lastPackBookmark() -> Data? {
        bookmark
    }

    func setLastPackBookmark(_ bookmark: Data?) {
        setCount += 1
        self.bookmark = bookmark
    }

    func recentPacks() -> [RecentPackRecord] {
        recents
    }

    func setRecentPacks(_ records: [RecentPackRecord]) {
        recents = records
    }
}
