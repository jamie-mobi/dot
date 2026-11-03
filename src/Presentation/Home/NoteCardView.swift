//
//  NoteCardView.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct NoteCardView: View {
    // MARK: - Input

    let card: NoteCard
    let colour: Color
    let label: String
    let now: Date
    let isFocused: Bool

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(card.path.name)
                .font(.headline)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                ForEach(Array(card.preview.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .lineLimit(1)
                }
            }
            .font(.callout)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: EditorMetrics.cardPreviewMinHeight, alignment: .topLeading)

            HStack(spacing: AppSpacing.small) {
                Text(RelativeAgeUseCase.age(of: card.modified, now: now).longText(for: card.modified))
                Spacer(minLength: AppSpacing.small)
                Text(label)
                    .lineLimit(1)
            }
            .font(.caption)
            .foregroundStyle(.tertiary)
        }
        .padding(AppSpacing.regular)
        .background(AppColor.surface, in: .rect(cornerRadius: AppRadius.card))
        .overlay(alignment: .top) {
            colour
                .frame(height: EditorMetrics.cardEdge)
        }
        .clipShape(.rect(cornerRadius: AppRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .strokeBorder(isFocused ? AppColor.accent : Color(nsColor: .separatorColor), lineWidth: isFocused ? EditorMetrics.focusRing : EditorMetrics.dividerThickness)
        }
        .shadow(color: AppColor.cardShadow, radius: EditorMetrics.cardShadowRadius, y: EditorMetrics.cardShadowOffset)
        .contentShape(.rect(cornerRadius: AppRadius.card))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
