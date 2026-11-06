//
//  NoteStatsText.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation
import OpalCore

enum NoteStatsText {
    // MARK: - Text

    static func counts(_ stats: NoteStats) -> String {
        [
            String(localized: "\(stats.words) words"),
            String(localized: "\(stats.links) Links"),
            String(localized: "\(stats.backlinks) Backlinks")
        ].joined(separator: " · ")
    }

    static func dates(_ stats: NoteStats, modified: Date?, now: Date) -> String {
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
