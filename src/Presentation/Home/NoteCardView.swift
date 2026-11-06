//
//  NoteCardView.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct NoteCardView: View {
    // MARK: - Input

    let item: HomeCard
    var isFocused = false

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(item.colour)
                .frame(height: EditorMetrics.cardEdge)

            preview
            Divider()
            footer
        }
        .frame(height: EditorMetrics.cardHeight)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(isFocused ? AppColor.accent : AppColor.line)
        }
        .shadow(color: AppColor.cardShadow, radius: AppSpacing.tiny, y: AppSpacing.tiny)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Preview

    private var preview: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            Text(item.card.path.name)
                .font(AppFont.cardTitle)
                .foregroundStyle(AppColor.text)
                .lineLimit(1)

            ForEach(Array(item.card.lines.enumerated()), id: \.offset) { _, line in
                CardLineView(line: line)
            }
        }
        .padding(.top, AppSpacing.snug)
        .padding(.horizontal, AppSpacing.regular)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipped()
        .mask {
            LinearGradient(stops: [.init(color: AppColor.fadeMask, location: EditorMetrics.cardFadeStart), .init(color: .clear, location: 1)], startPoint: .top, endPoint: .bottom)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: AppSpacing.small) {
            Text(item.edited)
            Spacer()
            LabelDot(colour: item.colour)
            Text(item.location)
                .lineLimit(1)
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.quietText)
        .padding(.horizontal, AppSpacing.regular)
        .frame(height: EditorMetrics.cardFooterHeight)
    }
}

#if DEBUG
    #Preview {
        let card = NoteCard(
            path: NotePath("Daily Notes/2026-11-03.md"),
            lines: [NotePreviewLine(text: "Mulched the tomato bed", isBullet: true), NotePreviewLine(text: "Rain due on Thursday. Hold off on watering.")],
            modified: .now,
            tag: nil
        )
        HStack {
            NoteCardView(item: HomeCard(card: card, colour: AppLabelColor.amber, location: "Daily Notes", edited: "3 hours ago"))
            NoteCardView(item: HomeCard(card: card, colour: AppLabelColor.neutral, location: "", edited: "Now"), isFocused: true)
        }
        .padding()
        .frame(width: EditorMetrics.windowMinWidth)
    }
#endif
