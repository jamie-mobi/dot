//
//  StarredNoteRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct StarredNoteRow: View {
    // MARK: - Input

    let path: NotePath
    let onOpen: () -> Void
    let onUnstar: () -> Void

    // MARK: - View

    var body: some View {
        Button(action: onOpen) {
            Label(path.name, systemImage: "star")
                .lineLimit(1)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(path.rawValue)
        .contextMenu {
            Button(String(localized: "Unstar"), action: onUnstar)
        }
    }
}
