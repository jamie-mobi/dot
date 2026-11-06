//
//  RecentPacksView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct RecentPacksView: View {
    // MARK: - Input

    let packs: [RecentPack]
    var onOpen: (RecentPack) -> Void = { _ in }
    var onRemove: (RecentPack) -> Void = { _ in }

    // MARK: - State

    @State private var hovered: RecentPack.ID?

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.tiny) {
            Text(String(localized: "Recent Packs"))
                .font(AppFont.label)
                .foregroundStyle(AppColor.quietText)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.small)

            if packs.isEmpty {
                Text(String(localized: "Packs you open show here."))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
                    .padding(.horizontal, AppSpacing.medium)
            }

            ScrollView {
                VStack(spacing: AppSpacing.tiny) {
                    ForEach(packs) { pack in
                        RecentPackRow(pack: pack, isSelected: pack.id == (hovered ?? packs.first?.id)) {
                            onOpen(pack)
                        } onRemove: {
                            onRemove(pack)
                        }
                        .onHover { isHovering in
                            hovered = isHovering ? pack.id : nil
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.regular)
        .padding(.horizontal, AppSpacing.medium)
        .frame(maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppRadius.panel))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.panel)
                .stroke(AppColor.line)
        }
    }
}
