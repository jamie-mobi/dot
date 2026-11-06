//
//  SearchFilterChip.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct SearchFilterChip: View {
    // MARK: - Input

    let title: String
    let isSelected: Bool
    var hasMenu = false

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.xsmall) {
            Text(title)
                .lineLimit(1)
            if hasMenu {
                Image(systemName: "chevron.down")
                    .imageScale(.small)
            }
        }
        .font(AppFont.caption)
        .foregroundStyle(isSelected ? AppColor.accent : AppColor.text)
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.compact)
        .background(isSelected ? AppColor.accentSoft : AppColor.surface, in: Capsule())
        .overlay {
            Capsule()
                .stroke(isSelected ? .clear : AppColor.line)
        }
        .contentShape(Capsule())
    }
}

#if DEBUG
    #Preview {
        HStack {
            SearchFilterChip(title: "All Folders", isSelected: false, hasMenu: true)
            SearchFilterChip(title: "Text and Properties", isSelected: true)
            SearchFilterChip(title: "Match Case", isSelected: false)
        }
        .padding()
    }
#endif
