//
//  TagSuggestionsBar.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct TagSuggestionsBar: View {
    // MARK: - Environment

    @Environment(\.tagSuggestionService) private var suggestions

    // MARK: - Input

    let document: NoteDocument

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            if isShown {
                TagSuggestionsView(state: state) { tag in
                    suggestions.accept(tag, in: document)
                    Usage.log("tag_suggestion_added")
                } onResuggest: {
                    Task { await suggestions.resuggest(for: document.path, text: text) }
                }
                .padding(.horizontal, AppSpacing.medium)
                .frame(minHeight: EditorMetrics.propertyRowHeight)
            }
        }
        .task(id: TagSuggestionKey(path: document.path, isOn: suggestions.isOn, isReady: document.isReady)) {
            guard document.isReady else {
                return
            }

            await suggestions.suggest(for: document.path, text: text)
        }
    }

    // MARK: - Derived

    private var state: TagSuggestionService.LoadState {
        suggestions.loadState(for: document.path)
    }

    private var isShown: Bool {
        switch state {
        case .suggesting, .suggested, .failed, .unavailable:
            true
        case .off, .waiting, .tooShort:
            false
        }
    }

    private var text: String {
        document.loadState.note?.text ?? ""
    }
}
