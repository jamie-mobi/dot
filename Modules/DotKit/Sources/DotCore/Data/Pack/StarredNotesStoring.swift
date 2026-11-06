//
//  StarredNotesStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public protocol StarredNotesStoring: Sendable {
    func starredNotes(forPackAt rootURL: URL) async -> [NotePath]
    func setStarredNotes(_ paths: [NotePath], forPackAt rootURL: URL) async
}
