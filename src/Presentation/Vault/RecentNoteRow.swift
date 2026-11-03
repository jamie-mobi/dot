//
//  RecentNoteRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import SwiftUI

struct RecentNoteRow: View {
    // MARK: - Input

    let note: RecentNote
    let onOpen: () -> Void

    // MARK: - View

    var body: some View {
        Button(action: onOpen) {
            HStack {
                Text(note.path.name)
                    .lineLimit(1)
                Spacer()
                if let age = note.age {
                    Text(age.shortText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(note.age.map { "\(note.path.name), \($0.shortText)" } ?? note.path.name)
        .help(note.path.rawValue)
    }
}
