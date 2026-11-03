//
//  SwitcherPreview.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct SwitcherPreview: View {
    // MARK: - Constants

    private enum Constants {
        static let lines = 14
    }

    // MARK: - Environment

    @Environment(\.serviceGraph) private var graph

    // MARK: - Input

    let path: NotePath?

    // MARK: - State

    @State private var lines: [String] = []

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            if let path {
                Text(path.name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.regular)
        .frame(width: EditorMetrics.switcherPreviewWidth, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(AppColor.fill)
        .task(id: path) {
            guard let path else {
                lines = []
                return
            }

            lines = await graph.home.preview(of: path, lines: Constants.lines)
        }
    }
}
