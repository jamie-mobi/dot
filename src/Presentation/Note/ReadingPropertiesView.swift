//
//  ReadingPropertiesView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct ReadingPropertiesView: View {
    // MARK: - Input

    let properties: [Property]
    let type: (Property) -> PropertyType

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            FlowLayout {
                ForEach(properties) { property in
                    item(property)
                }
            }
            .font(AppFont.caption)

            Divider()
        }
    }

    // MARK: - Item

    @ViewBuilder
    private func item(_ property: Property) -> some View {
        switch (type(property), property.value) {
        case let (.tags, .list(values)):
            ForEach(values, id: \.self) { tag in
                TagChip(text: "#\(tag)")
            }
        case let (.tags, .text(value)) where value.isEmpty == false:
            TagChip(text: "#\(value)")
        case let (_, .list(values)):
            labelled(property.key, value: Text(values.joined(separator: ", ")))
        case let (_, .text(value)):
            labelled(property.key, value: valueText(value))
        case let (_, .unreadable(raw)):
            labelled(property.key, value: Text(raw))
        }
    }

    private func valueText(_ value: String) -> Text {
        guard let match = value.wholeMatch(of: /\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]/) else {
            return Text(value)
        }

        return Text(String(match.output.2 ?? match.output.1)).foregroundStyle(AppColor.accent)
    }

    private func labelled(_ name: String, value: Text) -> some View {
        HStack(spacing: AppSpacing.xsmall) {
            Text(name)
                .foregroundStyle(AppColor.quietText)
            value
                .foregroundStyle(AppColor.text)
        }
    }
}
