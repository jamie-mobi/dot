//
//  TagSuggestionKey.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore

struct TagSuggestionKey: Hashable {
    // MARK: - Stored

    let path: NotePath
    let isOn: Bool
    let isReady: Bool
}
