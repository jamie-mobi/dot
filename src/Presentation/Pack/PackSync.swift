//
//  PackSync.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import SwiftUI

struct PackSync: View {
    // MARK: - Environment

    @Environment(\.serviceGraph) private var graph
    @Environment(\.packService) private var pack
    @Environment(\.indexService) private var index
    @Environment(\.searchService) private var search

    // MARK: - View

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .onChange(of: index.revision) {
                Task { await search.search() }
            }
            .onChange(of: pack.isOpen, initial: true) { _, isOpen in
                if isOpen {
                    Usage.log("pack_opened", ["notes": Usage.countBucket(pack.entries.count { $0.kind == .note })])
                }
            }
            .task(id: pack.entriesRevision) {
                await graph.syncFollowers()
            }
    }
}
