//
//  RecentNote.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore

struct RecentNote: Hashable, Identifiable {
    // MARK: - Stored

    let path: NotePath
    let age: RelativeAge?

    // MARK: - Identifiable

    var id: NotePath {
        path
    }
}
