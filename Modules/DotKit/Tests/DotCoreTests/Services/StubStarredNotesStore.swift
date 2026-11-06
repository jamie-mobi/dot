//
//  StubStarredNotesStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import DotCore

actor StubStarredNotesStore: StarredNotesStoring {
    // MARK: - Stored

    private(set) var stored: [URL: [NotePath]] = [:]

    // MARK: - StarredNotesStoring

    func starredNotes(forPackAt rootURL: URL) -> [NotePath] {
        stored[rootURL] ?? []
    }

    func setStarredNotes(_ paths: [NotePath], forPackAt rootURL: URL) {
        stored[rootURL] = paths
    }
}
