//
//  SearchResultGroupView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct SearchResultGroupView: View {
    // MARK: - Input

    let result: SearchResult
    let terms: [String]
    let location: String
    let colour: Color
    let selectedLine: SearchLineID?
    var onOpen: (Int?) -> Void = { _ in }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onOpen(nil)
            } label: {
                header
            }
            .buttonStyle(.plain)

            Divider()

            ForEach(result.lines, id: \.line) { line in
                Button {
                    onOpen(line.line)
                } label: {
                    row(line)
                }
                .buttonStyle(.plain)
                .id(SearchLineID(path: result.path, line: line.line))
            }
        }
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColor.line)
        }
        .shadow(color: AppColor.cardShadow, radius: AppSpacing.tiny, y: AppSpacing.tiny)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: "doc.text")
                .foregroundStyle(AppColor.quietText)
            Text(title)
                .font(AppFont.uiEmphasis)
                .foregroundStyle(AppColor.text)
                .lineLimit(1)
            Text(location)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.quietText)
                .lineLimit(1)
            Spacer()
            LabelDot(colour: colour)
            Text(result.matchCount == 1 ? String(localized: "1 match") : String(localized: "\(result.matchCount) matches"))
                .font(AppFont.caption)
                .foregroundStyle(AppColor.quietText)
                .monospacedDigit()
        }
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.medium)
        .contentShape(Rectangle())
        .help(result.path.rawValue)
    }

    private var title: AttributedString {
        terms.reduce(AttributedString(result.path.name)) { text, term in
            text.highlighting(term, background: AppColor.searchMatch)
        }
    }

    // MARK: - Row

    private func row(_ line: SearchLine) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
            Text(line.kind.title)
                .font(AppFont.label)
                .foregroundStyle(AppColor.quietText)
                .frame(width: EditorMetrics.resultKindWidth, alignment: .leading)
            Text(AttributedString.highlighting(line.highlights, in: line.text, background: AppColor.searchMatch))
                .font(AppFont.uiBody)
                .foregroundStyle(AppColor.text)
                .lineLimit(3)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.small)
        .background(SearchLineID(path: result.path, line: line.line) == selectedLine ? AppColor.accentSoft : .clear)
        .contentShape(Rectangle())
    }
}
