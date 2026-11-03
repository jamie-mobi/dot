//
//  BacklinksView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct BacklinksView: View {
    // MARK: - Input

    let groups: [BacklinkGroup]
    var mentions: [UnlinkedMention] = []
    var mentionCount = 0
    var onOpen: (Backlink) -> Void = { _ in }
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
                VStack(alignment: .leading, spacing: AppSpacing.comfortable) {
                    if groups.isEmpty == false {
                        HStack {
                            Text(String(localized: "Linked"))
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }

                    ForEach(groups) { group in
                        BacklinkCard(group: group, onOpen: onOpen)
                    }

                    UnlinkedMentionsSection(mentions: mentions, total: mentionCount, onOpen: onOpenMention, onLink: onLinkMention, onShowMore: onShowMoreMentions)
                        .padding(.top, AppSpacing.small)
                }
                .padding(AppSpacing.comfortable)
            }
        }
    }
}

#if DEBUG
    #Preview("Backlinks") {
        BacklinksView(groups: BacklinkGroupUseCase.groups([
            Backlink(
                source: NotePath("Gardening Basics.md"),
                link: Link(target: "Soil", span: TextSpan(location: 0, length: 8), line: 7, lineText: "Good soil comes first. Read [[Soil]] before you plant anything.")
            ),
            Backlink(
                source: NotePath("Tomatoes.md"),
                link: Link(target: "Soil", span: TextSpan(location: 0, length: 8), line: 7, lineText: "Grow them in full sun, in [[Soil|rich earth]].")
            )
        ]))
        .frame(width: 280, height: 400)
    }

    #Preview("Empty") {
        BacklinksView(groups: [])
            .frame(width: 280, height: 400)
    }
#endif
