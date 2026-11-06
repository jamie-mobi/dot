//
//  HomeSearchBar.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalDesign
import SwiftUI

struct HomeSearchBar: View {
    // MARK: - Input

    var onSearch: () -> Void = {}

    // MARK: - View

    var body: some View {
        Button(action: onSearch) {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColor.quietText)
                Text(String(localized: "Search Notes, Tags and Properties"))
                    .font(AppFont.searchField)
                    .foregroundStyle(AppColor.quietText)
                Spacer()
                KeyCapsView(keys: ["⇧⌘F"])
            }
            .padding(.leading, AppSpacing.regular)
            .padding(.trailing, AppSpacing.medium)
            .frame(height: EditorMetrics.searchBarHeight)
            .background(AppColor.field, in: RoundedRectangle(cornerRadius: AppRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .stroke(AppColor.strongLine)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(String(localized: "Search the Vault (⇧⌘F)"))
    }
}

#if DEBUG
    #Preview {
        HomeSearchBar()
            .padding()
    }
#endif
