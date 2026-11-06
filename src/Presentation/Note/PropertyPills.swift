//
//  PropertyPills.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotDesign
import SwiftUI

struct PropertyPills: View {
    // MARK: - Input

    let items: [String]

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.xsmall) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                TagChip(text: item, style: .neutral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
