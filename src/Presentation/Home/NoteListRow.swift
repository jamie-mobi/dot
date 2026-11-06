//
//  NoteListRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct NoteListRow: View {
    // MARK: - Input

    let item: HomeCard
    var isFocused = false

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.comfortable) {
            LabelDot(colour: item.colour)
            Text(item.card.path.name)
                .font(AppFont.cardTitle)
                .foregroundStyle(AppColor.text)
                .lineLimit(1)
            Spacer()
            Text(item.location)
                .lineLimit(1)
            Text(item.edited)
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.quietText)
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.medium)
        .background(isFocused ? AppColor.accentSoft : .clear)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
