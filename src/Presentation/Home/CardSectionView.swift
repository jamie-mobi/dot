//
//  CardSectionView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct CardSectionView<Item: View>: View {
    // MARK: - Kind

    enum Kind: Hashable {
        case recent
        case folder
    }

    // MARK: - Input

    let title: String
    let count: Int
    let kind: Kind
    let cards: [HomeCard]
    let layout: HomeLayout
    @ViewBuilder let item: (HomeCard) -> Item

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.comfortable) {
            header

            switch layout {
            case .cards:
                LazyVGrid(columns: columns, spacing: AppSpacing.snug) {
                    ForEach(cards) { card in
                        item(card)
                    }
                }
            case .list:
                VStack(spacing: 0) {
                    ForEach(cards) { card in
                        item(card)
                        if card != cards.last {
                            Divider()
                        }
                    }
                }
                .background(AppColor.surface, in: RoundedRectangle(cornerRadius: AppRadius.card))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: kind == .recent ? "clock" : "folder")
                .foregroundStyle(AppColor.quietText)
            Text(title)
                .font(AppFont.uiEmphasis)
                .foregroundStyle(AppColor.text)
            Text(count == 1 ? String(localized: "1 Note") : String(localized: "\(count) Notes"))
                .font(AppFont.caption)
                .foregroundStyle(AppColor.quietText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Layout

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: AppSpacing.snug), count: EditorMetrics.cardColumns)
    }
}
