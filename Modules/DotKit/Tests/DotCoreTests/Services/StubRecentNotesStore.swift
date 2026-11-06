//
//  StubRecentNotesStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
@testable import DotCore

actor StubRecentNotesStore: RecentNotesStoring {
    // MARK: - Stored

    private(set) var stored: [URL: [NotePath]] = [:]

    // MARK: - RecentNotesStoring

    func recentNotes(forPackAt rootURL: URL) -> [NotePath] {
        stored[rootURL] ?? []
    }

    func setRecentNotes(_ paths: [NotePath], forPackAt rootURL: URL) {
        stored[rootURL] = paths
    }
}
