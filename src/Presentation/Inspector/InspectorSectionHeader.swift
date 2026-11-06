//
//  InspectorSectionHeader.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct InspectorSectionHeader: View {
    // MARK: - Input

    let title: String
    let detail: String

    // MARK: - View

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.label)
                .foregroundStyle(AppColor.quietText)
            Spacer()
            Text(detail)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.quietText)
                .monospacedDigit()
        }
        .padding(.horizontal, AppSpacing.xsmall)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}
