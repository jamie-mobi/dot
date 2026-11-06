//
//  KeyCapsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalDesign
import SwiftUI

struct KeyCapsView: View {
    // MARK: - Input

    let keys: [String]

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.tiny) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Text(key)
                    .font(AppFont.keyCap)
                    .foregroundStyle(AppColor.secondaryText)
                    .padding(.horizontal, AppSpacing.compact)
                    .padding(.vertical, AppSpacing.tiny)
                    .background(AppColor.fill, in: RoundedRectangle(cornerRadius: AppRadius.tiny))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppRadius.tiny)
                            .stroke(AppColor.line)
                    }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
    #Preview {
        VStack {
            KeyCapsView(keys: ["⇧⌘F"])
            KeyCapsView(keys: ["⌘", "N"])
        }
        .padding()
    }
#endif
