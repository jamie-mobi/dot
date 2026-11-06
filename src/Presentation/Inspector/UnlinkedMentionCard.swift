//
//  UnlinkedMentionCard.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct UnlinkedMentionCard: View {
    // MARK: - Input

    let mention: UnlinkedMention
    var onOpen: () -> Void = {}
    var onLink: () -> Void = {}

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            HStack(spacing: AppSpacing.compact) {
                Image(systemName: "doc.text")
                    .foregroundStyle(AppColor.quietText)
                Text(mention.source.name)
                    .font(AppFont.cardPreviewEmphasis)
                    .foregroundStyle(AppColor.text)
                    .lineLimit(1)
                Spacer()
                Button(String(localized: "Link"), action: onLink)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                    .help(String(localized: "Turn “\(mention.matchedText)” in \(mention.source.name) into a Link"))
            }

            Text(AttributedString(mention.lineText.trimmingCharacters(in: .whitespaces)).highlighting(mention.matchedText, background: AppColor.searchMatch))
                .font(AppFont.cardPreview)
                .foregroundStyle(AppColor.secondaryText)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpacing.comfortable)
        .padding(.vertical, AppSpacing.medium)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.inner))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.inner)
                .stroke(AppColor.line)
        }
        .shadow(color: AppColor.cardShadow, radius: AppSpacing.tiny, y: AppSpacing.tiny)
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
        .accessibilityAction(named: String(localized: "Open"), onOpen)
    }
}
