//
//  BlockIDService.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class BlockIDService {
    // MARK: - Private

    private let vault: VaultService
    private let notes: NoteService

    // MARK: - Init

    public init(vault: VaultService, notes: NoteService) {
        self.vault = vault
        self.notes = notes
    }

    // MARK: - Intent

    public func plan(addingTo line: Int, in path: NotePath) async -> BlockIDPlan? {
        guard notes.document(for: path) == nil, let store = vault.store, let text = try? await store.readNote(at: path) else {
            return nil
        }

        var generator = SystemRandomNumberGenerator()
        let taken = Set(MarkdownNoteParser.parse(text).blocks.map(\.id))
        let id = BlockIDUseCase.newID(avoiding: taken, using: &generator)
        guard let updated = BlockIDUseCase.adding(id, toLine: line, in: text) else {
            return nil
        }

        return BlockIDPlan(path: path, id: id, line: line, original: text, updated: updated)
    }

    public func apply(_ plan: BlockIDPlan) async throws(VaultError) {
        guard let store = vault.store else {
            throw .noVaultOpen
        }

        guard notes.document(for: plan.path) == nil, try await store.readNote(at: plan.path) == plan.original else {
            throw .writeFailed(plan.path)
        }

        try await store.writeNote(plan.updated, at: plan.path)
        await vault.handleExternalChanges([plan.path])
    }
}
