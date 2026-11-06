//
//  KeyHintsView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct KeyHintsView: View {
    // MARK: - Input

    let hints: [KeyHint]

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.comfortable) {
            ForEach(hints) { hint in
                HStack(spacing: AppSpacing.xsmall) {
                    Text(hint.keys)
                        .font(AppFont.keyCap)
                        .foregroundStyle(AppColor.secondaryText)
                    Text(hint.title)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.quietText)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
    #Preview {
        KeyHintsView(hints: [KeyHint(keys: "↑↓", title: "Move"), KeyHint(keys: "↩", title: "Open"), .close])
            .padding()
    }
#endif
