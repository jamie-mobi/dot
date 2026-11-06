//
//  TagChip.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct TagChip: View {
    // MARK: - Style

    enum Style {
        case accent
        case neutral
    }

    // MARK: - Input

    let text: String
    var style = Style.accent

    // MARK: - View

    var body: some View {
        Text(text)
            .font(AppFont.caption)
            .lineLimit(1)
            .foregroundStyle(style == .accent ? AppColor.accent : AppColor.text)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, AppSpacing.tiny)
            .background(style == .accent ? AppColor.tagFill : AppColor.strongFill, in: Capsule())
    }
}

#if DEBUG
    #Preview {
        HStack {
            TagChip(text: "#garden")
            TagChip(text: "Love apples", style: .neutral)
        }
        .padding()
    }
#endif
