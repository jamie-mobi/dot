//
//  NoteStatusBar.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct NoteStatusBar: View {
    // MARK: - Input

    let stats: NoteStats
    let modified: Date?
    let now: Date

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Text(counts)
            Spacer(minLength: AppSpacing.regular)
            Text(dates)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .monospacedDigit()
        .lineLimit(1)
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.small)
    }

    // MARK: - Text

    private var counts: String {
        [
            String(localized: "\(stats.words) words"),
            String(localized: "\(stats.links) Links"),
            String(localized: "\(stats.backlinks) Backlinks")
        ].joined(separator: " · ")
    }

    private var dates: String {
        var parts: [String] = []
        if let created = stats.created {
            parts.append(String(localized: "Created \(created.formatted(.dateTime.day().month(.abbreviated).year()))"))
        }
        if let modified {
            parts.append(RelativeAgeUseCase.age(of: modified, now: now).editedText(for: modified))
        }
        return parts.joined(separator: " · ")
    }
}
