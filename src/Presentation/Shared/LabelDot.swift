//
//  LabelDot.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct LabelDot: View {
    // MARK: - Input

    let colour: Color

    // MARK: - View

    var body: some View {
        Circle()
            .fill(colour)
            .frame(width: EditorMetrics.labelDot, height: EditorMetrics.labelDot)
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview {
        HStack {
            LabelDot(colour: AppLabelColor.green)
            LabelDot(colour: AppLabelColor.blue)
            LabelDot(colour: AppLabelColor.neutral)
        }
        .padding()
    }
#endif
