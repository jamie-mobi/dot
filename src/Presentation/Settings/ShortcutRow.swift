//
//  ShortcutRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore
import DotDesign
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
                    shortcutButton
                }
                if let message {
                    Text(message)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.quietText)
                }
                if let onReplace, let onCancel {
                    HStack(spacing: AppSpacing.small) {
                        Button(String(localized: "Cancel"), action: onCancel)
                        Button(String(localized: "Replace"), action: onReplace)
                    }
                    .controlSize(.small)
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

    // MARK: - Shortcut

    @ViewBuilder
    private var shortcutButton: some View {
        if let shortcut, isRecording == false {
            Button(action: onRecord) {
                KeyCapsView(keys: shortcut.keyCaps)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(String(localized: "Change the shortcut for \(title)"))
            .accessibilityLabel(String(localized: "\(title), \(shortcut.text)"))
        } else {
            Button(isRecording ? String(localized: "Type Shortcut…") : String(localized: "Add Shortcut"), action: onRecord)
                .controlSize(.small)
                .help(String(localized: "Change the shortcut for \(title)"))
        }
    }
}
