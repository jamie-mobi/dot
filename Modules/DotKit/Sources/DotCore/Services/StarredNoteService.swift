//
//  StarredNoteService.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class StarredNoteService {
    // MARK: - State

    public private(set) var notes: [NotePath] = []

    // MARK: - Private

    private let pack: PackService
    private let store: any StarredNotesStoring
    private var loadedRoot: URL?

    // MARK: - Init

    public init(pack: PackService, store: any StarredNotesStoring) {
        self.pack = pack
        self.store = store
    }

    // MARK: - Lookup

    public func isStarred(_ path: NotePath) -> Bool {
        notes.contains(path)
    }

    // MARK: - Intent

    public func load() async {
        guard let root = pack.store?.rootURL, root != loadedRoot else {
            return
        }

        loadedRoot = root
        notes = await store.starredNotes(forPackAt: root)
    }

    public func toggle(_ path: NotePath) async {
        await load()
        if notes.contains(path) {
            notes.removeAll { $0 == path }
        } else {
            notes.append(path)
        }
        await save()
    }

    public func move(from old: NotePath, to new: NotePath) async {
        guard notes.contains(old) else {
            return
        }

        notes = notes.map { $0 == old ? new : $0 }
        await save()
    }

    public func forget(_ path: NotePath) async {
        guard notes.contains(path) else {
            return
        }

        notes.removeAll { $0 == path }
        await save()
    }

    // MARK: - Private

    private func save() async {
        guard let root = pack.store?.rootURL, root == loadedRoot else {
            return
        }

        await store.setStarredNotes(notes, forPackAt: root)
    }
}
