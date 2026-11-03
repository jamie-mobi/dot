//
//  KeyHintBar.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalDesign
import SwiftUI

struct KeyHintBar: View {
    // MARK: - Input

    let hints: [KeyHint]

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.regular) {
            ForEach(hints, id: \.self) { hint in
                HStack(spacing: AppSpacing.xsmall) {
                    Text(hint.keys)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, AppSpacing.xsmall)
                        .padding(.vertical, AppSpacing.tiny)
                        .background(AppColor.fill2, in: .rect(cornerRadius: AppRadius.row))
                    Text(hint.title)
                        .font(.caption)
                }
            }
            Spacer()
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, AppSpacing.regular)
        .padding(.vertical, AppSpacing.small)
        .accessibilityElement(children: .combine)
    }
}
