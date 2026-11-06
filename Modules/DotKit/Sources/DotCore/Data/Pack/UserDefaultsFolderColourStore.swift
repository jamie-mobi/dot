//
//  UserDefaultsFolderColourStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public final class UserDefaultsFolderColourStore: FolderColourStoring, @unchecked Sendable {
    // MARK: - Constants

    private enum Constants {
        static let keyPrefix = "folderColours."
    }

    // MARK: - Private

    private let defaults: UserDefaults

    // MARK: - Init

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    // MARK: - FolderColourStoring

    public func folderColours(forPackAt rootURL: URL) -> [NotePath: FolderColour] {
        let saved = defaults.dictionary(forKey: key(for: rootURL)) as? [String: String] ?? [:]
        return Dictionary(uniqueKeysWithValues: saved.compactMap { path, name in
            FolderColour(rawValue: name).map { (NotePath(path), $0) }
        })
    }

    public func setFolderColours(_ colours: [NotePath: FolderColour], forPackAt rootURL: URL) {
        defaults.set(Dictionary(uniqueKeysWithValues: colours.map { ($0.key.rawValue, $0.value.rawValue) }), forKey: key(for: rootURL))
    }

    // MARK: - Private

    private func key(for rootURL: URL) -> String {
        Constants.keyPrefix + rootURL.standardizedFileURL.path
    }
}
