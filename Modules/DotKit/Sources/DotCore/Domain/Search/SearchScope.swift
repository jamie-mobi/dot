//
//  SearchScope.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum SearchScope: String, CaseIterable, Hashable, Sendable {
    case all
    case text
    case properties

    // MARK: - Lines

    public func includes(isProperty: Bool) -> Bool {
        switch self {
        case .all:
            true
        case .text:
            isProperty == false
        case .properties:
            isProperty
        }
    }
}
