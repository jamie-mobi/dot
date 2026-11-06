//
//  SearchFieldView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct SearchFieldView: View {
    // MARK: - Binding

    @Binding var query: String

    // MARK: - Input

    var focusRequest = 0
    var onMove: (Int) -> Void = { _ in }
    var onSubmit: () -> Void = {}

    // MARK: - State

    @FocusState private var isFocused: Bool

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.quietText)

            TextField(String(localized: "Search Notes, Tags and Properties"), text: $query)
                .textFieldStyle(.plain)
                .font(AppFont.searchField)
                .focused($isFocused)
                .onSubmit(onSubmit)
                .onKeyPress(.downArrow) {
                    onMove(1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    onMove(-1)
                    return .handled
                }
                .help(String(localized: "Words, \"phrases\", -exclude, path:, file:, tag:#name"))

            if query.isEmpty == false {
                Button(String(localized: "Clear"), systemImage: "xmark", action: clear)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColor.quietText)
            }
        }
        .padding(.horizontal, AppSpacing.regular)
        .frame(height: EditorMetrics.searchBarHeight)
        .background(AppColor.field, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColor.accent)
        }
        .onAppear {
            isFocused = true
        }
        .onChange(of: focusRequest) {
            isFocused = true
        }
    }

    // MARK: - Actions

    private func clear() {
        query = ""
        isFocused = true
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var query = "soil"
        SearchFieldView(query: $query)
            .padding()
    }
#endif
