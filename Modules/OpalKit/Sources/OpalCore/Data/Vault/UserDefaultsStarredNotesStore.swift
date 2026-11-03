//
//  UserDefaultsStarredNotesStore.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public final class UserDefaultsStarredNotesStore: StarredNotesStoring, @unchecked Sendable {
    // MARK: - Constants

    private enum Constants {
        static let keyPrefix = "starredNotes."
    }

    // MARK: - Private

    private let defaults: UserDefaults

    // MARK: - Init

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    // MARK: - StarredNotesStoring

    public func starredNotes(forVaultAt rootURL: URL) -> [NotePath] {
        (defaults.stringArray(forKey: key(for: rootURL)) ?? []).map(NotePath.init)
    }

    public func setStarredNotes(_ paths: [NotePath], forVaultAt rootURL: URL) {
        defaults.set(paths.map(\.rawValue), forKey: key(for: rootURL))
    }

    // MARK: - Private

    private func key(for rootURL: URL) -> String {
        Constants.keyPrefix + rootURL.standardizedFileURL.path
    }
}
