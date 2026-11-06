//
//  OutgoingLinksView.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct OutgoingLinksView: View {
    // MARK: - Input

    let links: [OutgoingLink]
    var onFollow: (OutgoingLink) -> Void = { _ in }

    // MARK: - View

    var body: some View {
        if links.isEmpty {
            ContentUnavailableView(
                String(localized: "No Links"),
                systemImage: "arrow.up.right",
                description: Text(String(localized: "Type [[ in the Note to link to another Note."))
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                    InspectorSectionHeader(title: String(localized: "Links"), detail: String(links.count))
                        .padding(.bottom, AppSpacing.xsmall)

                    ForEach(links, id: \.self) { outgoing in
                        Button {
                            onFollow(outgoing)
                        } label: {
                            Label(title(of: outgoing), systemImage: outgoing.isResolved ? "arrow.up.right" : "plus.circle.dashed")
                                .font(AppFont.uiBody)
                                .foregroundStyle(outgoing.isResolved ? AppColor.accent : AppColor.unresolvedLink)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, minHeight: EditorMetrics.propertyRowHeight, alignment: .leading)
                                .padding(.horizontal, AppSpacing.small)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .help(outgoing.isResolved
                            ? String(localized: "Open \(outgoing.target?.rawValue ?? title(of: outgoing))")
                            : String(localized: "Create \(title(of: outgoing))"))
                    }
                }
                .padding(.horizontal, AppSpacing.comfortable)
            }
        }
    }

    // MARK: - Title

    private func title(of outgoing: OutgoingLink) -> String {
        outgoing.target?.name ?? outgoing.link.target
    }
}
