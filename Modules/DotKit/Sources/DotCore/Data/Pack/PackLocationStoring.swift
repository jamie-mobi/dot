//
//  PackLocationStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public protocol PackLocationStoring: Sendable {
    func lastPackBookmark() async -> Data?
    func setLastPackBookmark(_ bookmark: Data?) async
    func recentPacks() async -> [RecentPackRecord]
    func setRecentPacks(_ records: [RecentPackRecord]) async
}
