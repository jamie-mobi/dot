//
//  BacklinksView.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct BacklinksView: View {
    // MARK: - Input

    let groups: [BacklinkGroup]
    var mentions: [UnlinkedMention] = []
    var mentionCount = 0
    var onOpen: (NotePath, Int?) -> Void = { _, _ in }
    var onOpenMention: (UnlinkedMention) -> Void = { _ in }
    var onLinkMention: (UnlinkedMention) -> Void = { _ in }
    var onShowMoreMentions: () -> Void = {}

    // MARK: - Derived

    private var summary: String {
        let links = groups.reduce(0) { $0 + $1.backlinks.count }
        let notes = groups.count == 1 ? String(localized: "1 Note") : String(localized: "\(groups.count) Notes")
        let linkText = links == 1 ? String(localized: "1 Link") : String(localized: "\(links) Links")
        return "\(notes) · \(linkText)"
    }

    // MARK: - View

    var body: some View {
        if groups.isEmpty, mentions.isEmpty {
            ContentUnavailableView(
                String(localized: "No Backlinks"),
                systemImage: "arrow.uturn.backward",
                description: Text(String(localized: "No other Note links here yet."))
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    InspectorSectionHeader(title: String(localized: "Linked"), detail: groups.isEmpty ? "0" : summary)

                    ForEach(groups) { group in
                        BacklinkCard(group: group) { backlink in
                            onOpen(group.source, backlink?.link.line)
                        }
                    }

                    if mentions.isEmpty == false {
                        InspectorSectionHeader(title: String(localized: "Unlinked mentions"), detail: String(max(mentionCount, mentions.count)))
                            .padding(.top, AppSpacing.comfortable)

                        ForEach(mentions) { mention in
                            UnlinkedMentionCard(mention: mention) {
                                onOpenMention(mention)
                            } onLink: {
                                onLinkMention(mention)
                            }
                        }

                        if mentionCount > mentions.count {
                            Button(String(localized: "Show More (\(mentionCount - mentions.count, format: .number) left)"), action: onShowMoreMentions)
                                .buttonStyle(.link)
                                .font(AppFont.caption)
                                .padding(.horizontal, AppSpacing.xsmall)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.comfortable)
                .padding(.bottom, AppSpacing.comfortable)
            }
        }
    }
}
