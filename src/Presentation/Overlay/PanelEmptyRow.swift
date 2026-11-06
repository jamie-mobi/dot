//
//  PanelEmptyRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct PanelEmptyRow: View {
    // MARK: - Input

    let title: String
    var detail = ""

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.tiny) {
            Text(title)
                .font(AppFont.uiEmphasis)
                .foregroundStyle(AppColor.secondaryText)
            if detail.isEmpty == false {
                Text(detail)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.comfortable)
        .padding(.vertical, AppSpacing.small)
    }
}
