//
//  CommandPanelView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalDesign
import SwiftUI

struct CommandPanelView<Content: View>: View {
    // MARK: - Input

    let symbol: String
    let placeholder: String
    @Binding var query: String
    var shortcut: [String] = []
    let hints: [KeyHint]
    var scrollTarget: AnyHashable?
    var onMove: (Int) -> Void = { _ in }
    var onSubmit: () -> Void = {}
    var onCommandSubmit: (() -> Void)?
    @ViewBuilder let content: Content

    // MARK: - State

    @FocusState private var isQueryFocused: Bool

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppSpacing.comfortable) {
                Image(systemName: symbol)
                    .foregroundStyle(AppColor.quietText)
                TextField(placeholder, text: $query)
                    .textFieldStyle(.plain)
                    .font(AppFont.panelField)
                    .focused($isQueryFocused)
                    .onSubmit(onSubmit)
                KeyCapsView(keys: shortcut)
            }
            .padding(.horizontal, AppSpacing.spacious)
            .padding(.vertical, AppSpacing.regular)
            .onKeyPress(.downArrow) {
                onMove(1)
                return .handled
            }
            .onKeyPress(.upArrow) {
                onMove(-1)
                return .handled
            }
            .onKeyPress(.return, phases: .down) { press in
                guard press.modifiers.contains(.command), let onCommandSubmit else {
                    return .ignored
                }
                onCommandSubmit()
                return .handled
            }

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                        content
                    }
                    .padding(AppSpacing.small)
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(maxHeight: EditorMetrics.panelMaxListHeight)
                .onChange(of: scrollTarget) { _, target in
                    if let target {
                        proxy.scrollTo(target)
                    }
                }
            }

            Divider()

            HStack {
                KeyHintsView(hints: hints)
                Spacer()
                KeyHintsView(hints: [.close])
            }
            .padding(.horizontal, AppSpacing.regular)
            .padding(.vertical, AppSpacing.medium)
        }
        .frame(width: EditorMetrics.panelWidth)
        .fixedSize(horizontal: false, vertical: true)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppRadius.popover))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.popover)
                .stroke(AppColor.line)
        }
        .shadow(color: AppColor.popoverShadow, radius: EditorMetrics.panelShadowRadius, y: EditorMetrics.panelShadowY)
        .onAppear {
            isQueryFocused = true
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var query = "so"
        CommandPanelView(symbol: "magnifyingglass", placeholder: "Find a Note", query: $query, shortcut: ["⌘O"], hints: [KeyHint(keys: "↩", title: "Open")]) {
            Text(verbatim: "Soil")
            Text(verbatim: "The Soil Book")
        }
        .padding()
    }
#endif
