//
//  RecentPacksService.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class RecentPacksService {
    // MARK: - State

    public private(set) var packs: [RecentPack] = []

    // MARK: - Private

    private let access: any PackAccessGranting
    private let locations: any PackLocationStoring

    // MARK: - Init

    public init(access: any PackAccessGranting, locations: any PackLocationStoring) {
        self.access = access
        self.locations = locations
    }

    // MARK: - Intent

    public func load() async {
        let stored = await locations.recentPacks()
        var seen = Set<String>()
        let resolved = stored.map(resolve).filter { seen.insert($0.id).inserted }
        let records = resolved.map(\.record)
        if records != stored {
            await locations.setRecentPacks(records)
        }

        packs = resolved
    }

    public func record(_ folderURL: URL) async {
        let bookmark: Data
        do {
            bookmark = try access.bookmark(for: folderURL)
        } catch {
            AppLog.error("Could not remember the Pack in the recent list: \(error)")
            return
        }

        await load()
        let record = RecentPackRecord(bookmark: bookmark, path: folderURL.path(percentEncoded: false))
        await locations.setRecentPacks(RecentPacksUseCase.recording(record, in: packs.map(\.record)))
        await load()
    }

    public func remove(_ pack: RecentPack) async {
        await locations.setRecentPacks(packs.filter { $0.id != pack.id }.map(\.record))
        await load()
    }

    public func clear() async {
        await locations.setRecentPacks([])
        await load()
    }

    // MARK: - Private

    private func resolve(_ record: RecentPackRecord) -> RecentPack {
        guard let resolved = try? access.resolve(bookmark: record.bookmark) else {
            return RecentPack(record: record, folderURL: URL(filePath: record.path, directoryHint: .isDirectory), isMissing: true)
        }

        var isFolder: ObjCBool = false
        let exists = FileManager().fileExists(atPath: resolved.folderURL.path(percentEncoded: false), isDirectory: &isFolder)
        let updated = RecentPackRecord(bookmark: record.bookmark, path: resolved.folderURL.path(percentEncoded: false))
        return RecentPack(record: updated, folderURL: resolved.folderURL, isMissing: exists == false || isFolder.boolValue == false)
    }
}
