//
//  CommandRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct CommandRow: View {
    // MARK: - Input

    let command: AppCommand
    let keys: [String]
    let isSelected: Bool
    let isEnabled: Bool
    var onRun: () -> Void = {}

    // MARK: - View

    var body: some View {
        Button(action: onRun) {
            HStack {
                Text(command.title)
                    .font(AppFont.uiBody)
                    .foregroundStyle(AppColor.text)
                Spacer()
                KeyCapsView(keys: keys)
            }
            .padding(.horizontal, AppSpacing.comfortable)
            .padding(.vertical, AppSpacing.small)
            .background(isSelected ? AppColor.accentSoft : .clear, in: RoundedRectangle(cornerRadius: AppRadius.inner))
            .opacity(isEnabled ? 1 : AppOpacity.disabled)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityHint(isEnabled ? "" : String(localized: "Not available now"))
    }
}

#if DEBUG
    #Preview {
        VStack(spacing: 0) {
            CommandRow(command: .newNote, keys: ["⌘", "N"], isSelected: true, isEnabled: true)
            CommandRow(command: .duplicateNote, keys: [], isSelected: false, isEnabled: false)
        }
        .frame(width: EditorMetrics.panelWidth)
        .padding()
    }
#endif
