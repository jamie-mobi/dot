//
//  VaultHomeService.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Observation
import os

@MainActor
@Observable
public final class VaultHomeService {
    // MARK: - Constants

    public static let previewLines = 4

    // MARK: - State

    public private(set) var home = VaultHome.empty

    // MARK: - Private

    private let index: IndexService
    private let links: LinkService
    @ObservationIgnored private let signposter = OSSignposter(subsystem: "com.jamielesouef.Opal", category: "home")

    // MARK: - Init

    public init(index: IndexService, links: LinkService) {
        self.index = index
        self.links = links
    }

    // MARK: - Preview

    public func preview(of path: NotePath, lines: Int) async -> [String] {
        guard let store = index.store, let text = try? await store.texts(of: [path])[path] else {
            return []
        }

        return NotePreviewUseCase.preview(of: text, title: path.name, maxLines: lines)
    }

    // MARK: - Intent

    public func refresh() async {
        guard let store = index.store else {
            home = .empty
            return
        }

        let interval = signposter.beginInterval("Vault home")
        defer { signposter.endInterval("Vault home", interval) }
        do throws(IndexError) {
            let stamps = try await store.stamps()
            let layout = VaultHomeUseCase.layout(stamps: stamps)
            let texts = try await store.texts(of: layout.shownNotes)
            let parsed = links.map.parsed
            let card: (NotePath) -> NoteCard = { path in
                NoteCard(
                    path: path,
                    lines: NotePreviewUseCase.lines(of: texts[path] ?? "", title: path.name, maxLines: Self.previewLines),
                    modified: stamps[path]?.modified ?? .distantPast,
                    tag: parsed[path]?.tags.first
                )
            }
            home = VaultHome(
                noteCount: layout.noteCount,
                recent: layout.recent.map(card),
                groups: layout.groups.map { NoteCardGroup(folder: $0.folder, noteCount: $0.noteCount, cards: $0.notes.map(card)) }
            )
        } catch {
            AppLog.error("Building Vault home failed: \(error)")
        }
    }
}
