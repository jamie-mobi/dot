//
//  OutlineView.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct OutlineView: View {
    // MARK: - Input

    let headings: [Heading]
    var currentLine: Int?
    var counts = ""
    var dates = ""
    var onSelect: (Heading) -> Void = { _ in }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                InspectorSectionHeader(
                    title: String(localized: "Outline"),
                    detail: headings.count == 1 ? String(localized: "1 heading") : String(localized: "\(headings.count) headings")
                )
                .padding(.bottom, AppSpacing.xsmall)

                if headings.isEmpty {
                    Text(String(localized: "Start a line with # to add a Heading."))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.quietText)
                        .padding(.horizontal, AppSpacing.xsmall)
                }

                ForEach(headings, id: \.self) { heading in
                    Button {
                        onSelect(heading)
                    } label: {
                        row(heading)
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .padding(.vertical, AppSpacing.small)

                Text(counts.isEmpty || dates.isEmpty ? counts + dates : "\(counts)\n\(dates)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
                    .monospacedDigit()
                    .padding(.horizontal, AppSpacing.xsmall)
            }
            .padding(.horizontal, AppSpacing.comfortable)
        }
    }

    // MARK: - Row

    private var topLevel: Int {
        headings.map(\.level).min() ?? 1
    }

    private var current: Heading? {
        guard let currentLine else {
            return nil
        }

        return headings.last { $0.line <= currentLine }
    }

    private func row(_ heading: Heading) -> some View {
        Text(heading.text)
            .font(heading.level == topLevel ? AppFont.uiEmphasis : AppFont.uiBody)
            .foregroundStyle(AppColor.text)
            .lineLimit(1)
            .padding(.leading, CGFloat(max(heading.level - topLevel - 1, 0)) * AppSpacing.regular)
            .padding(.leading, heading.level == topLevel ? AppSpacing.small : AppSpacing.large)
            .frame(maxWidth: .infinity, minHeight: EditorMetrics.propertyRowHeight, alignment: .leading)
            .background(heading == current ? AppColor.selection : .clear, in: RoundedRectangle(cornerRadius: AppRadius.row))
            .contentShape(Rectangle())
    }
}
