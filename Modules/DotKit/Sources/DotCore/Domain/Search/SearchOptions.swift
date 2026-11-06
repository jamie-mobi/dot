//
//  SearchOptions.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public struct SearchOptions: Hashable, Sendable {
    // MARK: - Stored

    public var matchesCase: Bool
    public var scope: SearchScope

    // MARK: - Init

    public init(matchesCase: Bool = false, scope: SearchScope = .all) {
        self.matchesCase = matchesCase
        self.scope = scope
    }

    // MARK: - Derived

    public var isDefault: Bool {
        matchesCase == false && scope == .all
    }

    public var compareOptions: String.CompareOptions {
        matchesCase ? [.diacriticInsensitive] : [.caseInsensitive, .diacriticInsensitive]
    }
}
