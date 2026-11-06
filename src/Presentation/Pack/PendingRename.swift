//
//  PendingRename.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore

struct PendingRename: Identifiable {
    // MARK: - Stored

    let path: NotePath
    let plan: RenamePlan

    // MARK: - Identifiable

    var id: NotePath {
        path
    }
}
