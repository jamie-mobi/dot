//
//  ShortcutRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct ShortcutRow: View {
    // MARK: - Input

    let title: String
    let shortcut: CommandShortcut?
    let isRecording: Bool
    let message: String?
    let onRecord: () -> Void

    // MARK: - View

    var body: some View {
        LabeledContent {
            VStack(alignment: .trailing, spacing: AppSpacing.xsmall) {
                Button(action: onRecord) {
                    Text(label)
                        .monospacedDigit()
                }
                .help(String(localized: "Change the shortcut for \(title)"))
                .accessibilityLabel(String(localized: "\(title), \(label)"))
                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } label: {
            Text(title)
        }
    }

    // MARK: - Words

    private var label: String {
        if isRecording {
            return String(localized: "Type Shortcut…")
        }

        return shortcut?.text ?? String(localized: "Add Shortcut")
    }
}
