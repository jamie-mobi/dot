//
//  TagSuggestionKey.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore

struct TagSuggestionKey: Hashable {
    // MARK: - Stored

    let path: NotePath
    let isOn: Bool
    let isReady: Bool
}
