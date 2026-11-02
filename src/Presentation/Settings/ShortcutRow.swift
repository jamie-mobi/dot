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
    var onReplace: (() -> Void)?
    var onCancel: (() -> Void)?
    var onRemove: (() -> Void)?
    var onRestore: (() -> Void)?
    let onRecord: () -> Void

    // MARK: - View

    var body: some View {
        LabeledContent {
            VStack(alignment: .trailing, spacing: AppSpacing.xsmall) {
                HStack(spacing: AppSpacing.small) {
                    if let onRestore {
                        Button(String(localized: "Restore Default"), systemImage: "arrow.uturn.backward", action: onRestore)
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                            .help(String(localized: "Restore the default shortcut for \(title)"))
                    }
                    Button(action: onRecord) {
                        Text(label)
                            .monospacedDigit()
                    }
                    .help(String(localized: "Change the shortcut for \(title)"))
                    .accessibilityLabel(String(localized: "\(title), \(label)"))
                }
                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let onReplace, let onCancel {
                    HStack(spacing: AppSpacing.small) {
                        Button(String(localized: "Cancel"), action: onCancel)
                        Button(String(localized: "Replace"), action: onReplace)
                    }
                }
            }
        } label: {
            Text(title)
        }
        .contextMenu {
            if let onRemove {
                Button(String(localized: "Remove Shortcut"), action: onRemove)
            }
            if let onRestore {
                Button(String(localized: "Restore Default"), action: onRestore)
            }
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
