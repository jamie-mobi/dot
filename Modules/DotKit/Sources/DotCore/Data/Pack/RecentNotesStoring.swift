//
//  RecentNotesStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public protocol RecentNotesStoring: Sendable {
    func recentNotes(forPackAt rootURL: URL) async -> [NotePath]
    func setRecentNotes(_ paths: [NotePath], forPackAt rootURL: URL) async
}
