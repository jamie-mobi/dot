//
//  NoteCardRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct NoteCardRow: View {
    // MARK: - Input

    let card: NoteCard
    let colour: Color
    let label: String
    let now: Date
    let isFocused: Bool

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.comfortable) {
            Circle()
                .fill(colour)
                .frame(width: EditorMetrics.labelDotSize, height: EditorMetrics.labelDotSize)
            VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                Text(card.path.name)
                    .lineLimit(1)
                if let first = card.preview.first {
                    Text(first)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: AppSpacing.small)
            Text(label)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .lineLimit(1)
            Text(RelativeAgeUseCase.age(of: card.modified, now: now).shortText)
                .font(.caption)
                .foregroundStyle(.tertiary)
                .monospacedDigit()
        }
        .padding(.vertical, AppSpacing.small)
        .padding(.horizontal, AppSpacing.comfortable)
        .background(isFocused ? AppColor.accentSoft : Color.clear, in: .rect(cornerRadius: AppRadius.inner))
        .contentShape(.rect(cornerRadius: AppRadius.inner))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
