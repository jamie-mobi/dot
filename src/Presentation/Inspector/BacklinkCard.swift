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
    let onOpen: (Backlink) -> Void

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                Text(group.source.name)
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)
                if group.source.parent.isRoot == false {
                    Text(group.source.parent.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: AppSpacing.small)
                Text(group.backlinks.count == 1 ? String(localized: "1 Link") : String(localized: "\(group.backlinks.count) Links"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }

            ForEach(Array(zip(group.backlinks, BacklinkGroupUseCase.markedContexts(in: group))), id: \.0) { backlink, context in
                Button {
                    onOpen(backlink)
                } label: {
                    Text(attributed(context))
                        .font(.callout)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .help(String(localized: "Open \(group.source.name) at this line"))
            }
        }
        .padding(AppSpacing.comfortable)
        .background(AppColor.surface, in: .rect(cornerRadius: AppRadius.inner))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.inner)
                .strokeBorder(Color(nsColor: .separatorColor))
        }
    }

    // MARK: - Text

    private func attributed(_ context: BacklinkContext) -> AttributedString {
        var marked = AttributedString(context.marked)
        marked.backgroundColor = AppColor.mark
        marked.foregroundColor = AppColor.accent
        let lead = context.embed.map { AttributedString($0.title + " ") } ?? AttributedString()
        return AttributedString(context.before) + lead + marked + AttributedString(context.after)
    }
}
