//
//  PropertyPills.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalDesign
import SwiftUI

struct PropertyPills: View {
    // MARK: - Input

    let items: [String]
    let isTag: Bool

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.xsmall) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Text(item)
                    .lineLimit(1)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, AppSpacing.tiny)
                    .foregroundStyle(isTag ? AppColor.accent : Color.primary)
                    .background(isTag ? AppColor.accentSoft : AppColor.fill2, in: .capsule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
