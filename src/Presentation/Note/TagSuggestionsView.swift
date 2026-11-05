//
//  TagSuggestionsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct TagSuggestionsView: View {
    // MARK: - Input

    let state: TagSuggestionService.LoadState
    var onAccept: (String) -> Void = { _ in }
    var onResuggest: () -> Void = {}

    // MARK: - View

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.small) {
            Image(systemName: "sparkles")
                .foregroundStyle(AppColor.accent)
                .frame(width: EditorMetrics.propertyIconWidth)
                .help(String(localized: "Tags suggested by Apple Intelligence"))
                .accessibilityLabel(String(localized: "Suggested Tags"))
            content
            Spacer(minLength: 0)
            if isResuggestable {
                Button {
                    onResuggest()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .help(String(localized: "Suggest Tags again"))
                .accessibilityLabel(String(localized: "Suggest Tags again"))
            }
        }
        .font(.callout)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch state {
        case .suggesting:
            ProgressView()
                .controlSize(.small)
            Text(String(localized: "Suggesting Tags…"))
                .foregroundStyle(.secondary)
        case let .suggested(tags):
            if tags.isEmpty {
                Text(String(localized: "No more Tags to suggest"))
                    .foregroundStyle(.secondary)
            } else {
                pills(tags)
            }
        case .failed(.noteTooLong):
            Text(String(localized: "This Note is too long for Tag suggestions"))
                .foregroundStyle(.secondary)
        case .failed(.declined):
            Text(String(localized: "Apple Intelligence did not suggest Tags for this Note"))
                .foregroundStyle(.secondary)
        case .failed(.failed), .failed(.unavailable):
            Text(String(localized: "Tags could not be suggested"))
                .foregroundStyle(.secondary)
        case .off, .unavailable, .waiting, .tooShort:
            EmptyView()
        }
    }

    private func pills(_ tags: [String]) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: AppSpacing.xsmall) {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        onAccept(tag)
                    } label: {
                        Label("#\(tag)", systemImage: "plus")
                            .lineLimit(1)
                            .padding(.horizontal, AppSpacing.small)
                            .padding(.vertical, AppSpacing.tiny)
                            .foregroundStyle(AppColor.accent)
                            .background(AppColor.fill2, in: .capsule)
                            .contentShape(.capsule)
                    }
                    .buttonStyle(.plain)
                    .help(String(localized: "Add #\(tag) to this Note's tags"))
                }
            }
        }
        .scrollIndicators(.never)
    }

    // MARK: - Derived

    private var isResuggestable: Bool {
        switch state {
        case .suggested, .failed:
            true
        case .off, .unavailable, .waiting, .tooShort, .suggesting:
            false
        }
    }
}

#if DEBUG
    #Preview("Suggested") {
        TagSuggestionsView(state: .suggested(["gardening", "soil", "compost"]))
            .padding()
            .frame(width: 480)
    }

    #Preview("Suggesting") {
        TagSuggestionsView(state: .suggesting)
            .padding()
            .frame(width: 480)
    }

    #Preview("Failed") {
        TagSuggestionsView(state: .failed(.noteTooLong))
            .padding()
            .frame(width: 480)
    }
#endif
