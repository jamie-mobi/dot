//
//  NoteTagsView.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct NoteTagsView: View {
    // MARK: - Input

    let tags: [String]
    var onSelect: (String) -> Void = { _ in }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                InspectorSectionHeader(title: String(localized: "Tags"), detail: String(tags.count))

                if tags.isEmpty {
                    Text(String(localized: "Write #tag in the Note, or add a tags Property."))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.quietText)
                        .padding(.horizontal, AppSpacing.xsmall)
                }

                ForEach(tags, id: \.self) { tag in
                    Button {
                        onSelect(tag)
                    } label: {
                        TagChip(text: "#\(tag)")
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Search for Notes with #\(tag)"))
                }
            }
            .padding(.horizontal, AppSpacing.comfortable)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
