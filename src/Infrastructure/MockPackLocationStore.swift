//
//  MockPackLocationStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

#if DEBUG
    import Foundation
    import DotCore

    actor MockPackLocationStore: PackLocationStoring {
        // MARK: - Stored

        private var bookmark: Data?
        private var recents: [RecentPackRecord] = []

        // MARK: - PackLocationStoring

        func lastPackBookmark() -> Data? {
            bookmark
        }

        func setLastPackBookmark(_ bookmark: Data?) {
            self.bookmark = bookmark
        }

        func recentPacks() -> [RecentPackRecord] {
            recents
        }

        func setRecentPacks(_ records: [RecentPackRecord]) {
            recents = records
        }
    }
#endif
