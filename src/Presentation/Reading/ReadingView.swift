//
//  ReadingView.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct ReadingView<Header: View>: View {
    // MARK: - Environment

    @Environment(\.editorStyle) private var style

    // MARK: - Input

    let source: NotePath
    let blocks: [ReadingBlock]
    let startLine: () -> Int
    var onTopLine: (Int) -> Void = { _ in }
    var onFollowLink: (DotCore.Link) -> Void = { _ in }
    var onToggleCheckbox: (Int) -> Void = { _ in }
    @ViewBuilder var header: () -> Header

    // MARK: - State

    @State private var position: ReadingBlockID?

    // MARK: - View

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.regular) {
                header()
                    .textSelection(.disabled)
                ForEach(blocks) { block in
                    ReadingBlockView(block: block, chain: [source], onToggleCheckbox: onToggleCheckbox)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(style.readingFont)
                        .lineHeight(.exact(points: style.lineHeight))
                }
            }
            .scrollTargetLayout()
            .textSelection(.enabled)
            .frame(maxWidth: style.lineWidth > 0 ? style.lineWidth : .infinity)
            .padding(.horizontal, EditorMetrics.textInset)
            .padding(.vertical, AppSpacing.roomy)
            .frame(maxWidth: .infinity)
        }
        .scrollPosition(id: $position, anchor: .top)
        .tint(AppColor.accent)
        .background(AppColor.editorBackground)
        .environment(\.openURL, OpenURLAction { url in
            guard let offset = ReadingText.linkOffset(of: url), let link = links[offset] else {
                return .systemAction
            }

            onFollowLink(link)
            return .handled
        })
        .onAppear(perform: scrollToStart)
        .onChange(of: blocks) {
            if position == nil {
                scrollToStart()
            }
        }
        .onChange(of: position) { _, id in
            if let id {
                onTopLine(id.line)
            }
        }
    }

    // MARK: - Scroll

    private func scrollToStart() {
        let startLine = startLine()
        position = blocks.last { $0.line <= startLine && $0.isHeading }?.id ?? blocks.last { $0.line <= startLine }?.id
    }

    // MARK: - Links

    private var links: [Int: DotCore.Link] {
        var result: [Int: DotCore.Link] = [:]
        for block in blocks {
            for inline in block.inlines {
                if let link = inline.link {
                    result[link.span.location] = link
                }
            }
        }
        return result
    }
}
