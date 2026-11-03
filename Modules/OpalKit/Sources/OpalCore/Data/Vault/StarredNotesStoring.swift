//
//  StarredNotesStoring.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public protocol StarredNotesStoring: Sendable {
    func starredNotes(forVaultAt rootURL: URL) async -> [NotePath]
    func setStarredNotes(_ paths: [NotePath], forVaultAt rootURL: URL) async
}
