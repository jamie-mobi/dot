//
//  QuickSwitcherRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct QuickSwitcherRow: View {
    // MARK: - Input

    let match: SwitcherMatch
    let query: String
    let location: String
    let colour: Color
    let isSelected: Bool
    var onOpen: () -> Void = {}

    // MARK: - Derived

    private var highlightedName: AttributedString {
        let name = match.path.name
        var text = AttributedString(name)
        let marked = Set(FuzzyHighlightUseCase.marked(query, in: name))
        for (offset, index) in text.characters.indices.enumerated() where marked.contains(offset) {
            let next = text.characters.index(after: index)
            text[index ..< next].foregroundColor = AppColor.accent
        }
        return text
    }

    // MARK: - View

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: AppSpacing.comfortable) {
                Image(systemName: "doc.text")
                    .foregroundStyle(AppColor.quietText)

                VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                    Text(highlightedName)
                        .font(AppFont.uiEmphasis)
                        .foregroundStyle(AppColor.text)
                        .lineLimit(1)
                    HStack(spacing: AppSpacing.compact) {
                        LabelDot(colour: colour)
                        if let alias = match.matchedAlias {
                            Label(alias, systemImage: "arrow.turn.down.right")
                        } else {
                            Text(location)
                        }
                    }
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
                    .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    KeyCapsView(keys: ["↩"])
                }
            }
            .padding(.horizontal, AppSpacing.comfortable)
            .padding(.vertical, AppSpacing.small)
            .background(isSelected ? AppColor.accentSoft : .clear, in: RoundedRectangle(cornerRadius: AppRadius.inner))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(match.path.rawValue)
    }
}

#if DEBUG
    #Preview {
        VStack(spacing: 0) {
            QuickSwitcherRow(match: SwitcherMatch(path: NotePath("Soil.md")), query: "so", location: "Garden · also Dirt, Earth", colour: AppLabelColor.green, isSelected: true)
            QuickSwitcherRow(match: SwitcherMatch(path: NotePath("Reading/The Soil Book.md")), query: "so", location: "Reading", colour: AppLabelColor.purple, isSelected: false)
        }
        .frame(width: EditorMetrics.panelWidth)
        .padding()
    }
#endif
