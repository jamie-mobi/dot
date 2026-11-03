//
//  RecentNote.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

struct RecentNote: Hashable, Identifiable {
    // MARK: - Stored

    let path: NotePath
    let age: RelativeAge?

    // MARK: - Identifiable

    var id: NotePath {
        path
    }
}
