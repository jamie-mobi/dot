//
//  BacklinkCard.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct BacklinkCard: View {
    // MARK: - Input

    let group: BacklinkGroup
    let onOpen: (Backlink?) -> Void

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            Button {
                onOpen(nil)
            } label: {
                HStack(spacing: AppSpacing.compact) {
                    Image(systemName: "doc.text")
                        .foregroundStyle(AppColor.quietText)
                    Text(group.source.name)
                        .font(AppFont.cardPreviewEmphasis)
                        .foregroundStyle(AppColor.text)
                        .lineLimit(1)
                    Spacer()
                    Text(badge)
                        .font(AppFont.label)
                        .foregroundStyle(AppColor.quietText)
                        .monospacedDigit()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(group.source.rawValue)

            ForEach(Array(zip(group.backlinks, BacklinkGroupUseCase.markedContexts(in: group))), id: \.0) { backlink, context in
                Button {
                    onOpen(backlink)
                } label: {
                    Text(attributed(context))
                        .font(AppFont.cardPreview)
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(String(localized: "Open \(group.source.name) at this line"))
            }
        }
        .padding(.horizontal, AppSpacing.comfortable)
        .padding(.vertical, AppSpacing.medium)
        .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.inner))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.inner)
                .stroke(AppColor.line)
        }
        .shadow(color: AppColor.cardShadow, radius: AppSpacing.tiny, y: AppSpacing.tiny)
    }

    // MARK: - Text

    private var badge: String {
        if group.backlinks.allSatisfy({ BacklinkEmbed($0.link) != nil }) {
            return String(localized: "Embed")
        }
        return group.backlinks.count == 1 ? String(localized: "1 Link") : String(localized: "\(group.backlinks.count) Links")
    }

    private func attributed(_ context: BacklinkContext) -> AttributedString {
        var marked = AttributedString(context.marked)
        marked.backgroundColor = AppColor.searchMatch
        marked.foregroundColor = AppColor.text
        let lead = context.embed.map { AttributedString($0.title + " ") } ?? AttributedString()
        return AttributedString(context.before) + lead + marked + AttributedString(context.after)
    }
}
