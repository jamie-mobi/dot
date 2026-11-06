//
//  NoteHeaderView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct NoteHeaderView: View {
    // MARK: - Input

    let document: NoteDocument
    let isReading: Bool
    let pane: Int

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.comfortable) {
            Text(document.path.name)
                .font(isReading ? AppFont.readingTitle : AppFont.noteTitle)
                .foregroundStyle(AppColor.text)
                .lineLimit(2)
                .textSelection(.enabled)
                .accessibilityAddTraits(.isHeader)

            if let frontmatter = document.frontmatter, frontmatter.properties.isEmpty == false || frontmatter.isReadable == false {
                if isReading {
                    ReadingPropertiesView(properties: frontmatter.properties) { document.type(of: $0) }
                } else {
                    PropertiesView(document: document, frontmatter: frontmatter, pane: pane)
                }
            }

            TagSuggestionsBar(document: document)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
