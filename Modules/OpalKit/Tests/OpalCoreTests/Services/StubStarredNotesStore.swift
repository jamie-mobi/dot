//
//  StubStarredNotesStore.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import OpalCore

actor StubStarredNotesStore: StarredNotesStoring {
    // MARK: - Stored

    private(set) var stored: [URL: [NotePath]] = [:]

    // MARK: - StarredNotesStoring

    func starredNotes(forVaultAt rootURL: URL) -> [NotePath] {
        stored[rootURL] ?? []
    }

    func setStarredNotes(_ paths: [NotePath], forVaultAt rootURL: URL) {
        stored[rootURL] = paths
    }
}
