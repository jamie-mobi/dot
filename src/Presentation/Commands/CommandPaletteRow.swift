//
//  CommandPaletteRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import OpalDesign
import SwiftUI

struct CommandPaletteRow: View {
    // MARK: - Input

    let command: AppCommand
    let shortcutText: String
    let isSelected: Bool
    let isEnabled: Bool

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            Text(command.group)
                .font(.caption)
                .opacity(AppOpacity.subdued)
                .frame(width: EditorMetrics.shortcutGroupWidth, alignment: .leading)
            Text(command.title)
                .lineLimit(1)
            Spacer(minLength: AppSpacing.small)
            if shortcutText.isEmpty == false {
                Text(shortcutText)
                    .font(.callout.monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, AppSpacing.xsmall)
                    .padding(.vertical, AppSpacing.tiny)
                    .background(AppColor.fill2, in: .rect(cornerRadius: AppRadius.row))
            }
        }
        .foregroundStyle(isSelected ? AppColor.accent : .primary)
        .opacity(isEnabled ? 1 : AppOpacity.disabled)
        .padding(.horizontal, AppSpacing.small)
        .padding(.vertical, AppSpacing.compact)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: AppRadius.inner, style: .continuous)
                    .fill(AppColor.accentSoft)
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityHint(isEnabled ? "" : String(localized: "Not available now"))
    }
}
