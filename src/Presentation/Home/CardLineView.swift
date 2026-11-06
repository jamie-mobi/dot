//
//  CardLineView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct CardLineView: View {
    // MARK: - Input

    let line: NotePreviewLine

    // MARK: - View

    var body: some View {
        Group {
            if line.isBullet {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
                    Text(verbatim: "•")
                    Text(line.text)
                }
            } else {
                Text(line.text)
            }
        }
        .font(AppFont.cardPreview)
        .foregroundStyle(AppColor.secondaryText)
        .lineSpacing(EditorMetrics.cardLineSpacing)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
    #Preview {
        VStack(alignment: .leading) {
            CardLineView(line: NotePreviewLine(text: "Soil is a mix of sand, silt, clay and organic matter."))
            CardLineView(line: NotePreviewLine(text: "Mulched the tomato bed", isBullet: true))
        }
        .padding()
        .frame(width: EditorMetrics.inspectorWidth)
    }
#endif
