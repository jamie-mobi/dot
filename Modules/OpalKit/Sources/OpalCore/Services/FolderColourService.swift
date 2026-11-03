//
//  FolderColourService.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class FolderColourService {
    // MARK: - State

    public private(set) var colours: [NotePath: FolderColour] = [:]

    // MARK: - Private

    private let vault: VaultService
    private let store: any FolderColourStoring
    private var loadedRoot: URL?

    // MARK: - Init

    public init(vault: VaultService, store: any FolderColourStoring) {
        self.vault = vault
        self.store = store
    }

    // MARK: - Lookup

    public func colour(for path: NotePath) -> FolderColour? {
        FolderColourUseCase.colour(for: path, in: colours)
    }

    public func ownColour(of folder: NotePath) -> FolderColour? {
        colours[folder]
    }

    // MARK: - Intent

    public func load() async {
        guard let root = vault.store?.rootURL, root != loadedRoot else {
            return
        }

        loadedRoot = root
        colours = await store.folderColours(forVaultAt: root)
    }

    public func set(_ colour: FolderColour?, for folder: NotePath) async {
        await load()
        colours[folder] = colour
        await save()
    }

    public func move(from old: NotePath, to new: NotePath) async {
        let moved = FolderColourUseCase.moving(colours, from: old, to: new)
        guard moved != colours else {
            return
        }

        colours = moved
        await save()
    }

    public func forget(_ path: NotePath) async {
        let kept = FolderColourUseCase.forgetting(path, in: colours)
        guard kept != colours else {
            return
        }

        colours = kept
        await save()
    }

    // MARK: - Private

    private func save() async {
        guard let root = vault.store?.rootURL, root == loadedRoot else {
            return
        }

        await store.setFolderColours(colours, forVaultAt: root)
    }
}
