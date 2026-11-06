//
//  PropertyRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct PropertyRow: View {
    // MARK: - Input

    let document: NoteDocument
    let property: Property
    let type: PropertyType

    // MARK: - State

    @State private var draft = ""
    @FocusState private var isFocused: Bool
    @State private var isEditing = false

    // MARK: - View

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: type.systemImage)
                    .help(type.title)
                Text(property.key)
                    .lineLimit(1)
            }
            .foregroundStyle(AppColor.secondaryText)
            .frame(maxWidth: EditorMetrics.propertyNameWidth, alignment: .leading)

            editor
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(AppFont.uiBody)
        .padding(.horizontal, AppSpacing.medium)
        .frame(minHeight: EditorMetrics.propertyRowHeight)
        .contextMenu {
            Button(String(localized: "Remove Property"), role: .destructive) {
                document.removeProperty(property)
            }
        }
        .onAppear { draft = text }
        .onChange(of: property) { draft = text }
    }

    // MARK: - Editor

    @ViewBuilder
    private var editor: some View {
        switch (type, property.value) {
        case let (_, .unreadable(raw)):
            Text(raw)
                .font(AppFont.code)
                .foregroundStyle(AppColor.secondaryText)
                .lineLimit(1)
        case (.checkbox, _):
            Toggle(property.key, isOn: Binding {
                draft.lowercased() == "true"
            } set: { isOn in
                document.setProperty(property, to: .text(isOn ? "true" : "false"))
            })
            .labelsHidden()
        case (.list, _), (.tags, _), (.aliases, _):
            if isEditing || items.isEmpty {
                field(prompt: String(localized: "Comma-separated")) {
                    document.setProperty(property, to: .list(draft.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { $0.isEmpty == false }))
                }
            } else {
                PropertyPills(items: items)
                    .onTapGesture(perform: startEditing)
                    .help(String(localized: "Click to edit"))
            }
        case (.text, _) where isEditing == false && linkTarget != nil:
            Text(linkTarget ?? "")
                .foregroundStyle(AppColor.accent)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(perform: startEditing)
                .help(String(localized: "Click to edit"))
        case (.text, _), (.number, _), (.date, _), (.dateTime, _):
            field(prompt: type == .date ? "YYYY-MM-DD" : String(localized: "Empty")) {
                document.setProperty(property, to: .text(draft.trimmingCharacters(in: .whitespaces)))
            }
        }
    }

    private func field(prompt: String, commit: @escaping () -> Void) -> some View {
        TextField(property.key, text: $draft, prompt: Text(prompt))
            .labelsHidden()
            .textFieldStyle(.plain)
            .foregroundStyle(AppColor.text)
            .focused($isFocused)
            .onAppear {
                if isEditing {
                    isFocused = true
                }
            }
            .onSubmit {
                if draft != text {
                    commit()
                }
                isEditing = false
            }
            .onChange(of: isFocused) {
                guard isFocused == false else {
                    return
                }
                if draft != text {
                    commit()
                }
                isEditing = false
            }
    }

    // MARK: - Derived

    private var items: [String] {
        switch property.value {
        case let .list(values):
            values
        case let .text(value):
            value.isEmpty ? [] : [value]
        case .unreadable:
            []
        }
    }

    private var text: String {
        switch property.value {
        case let .text(value):
            value
        case let .list(values):
            values.joined(separator: ", ")
        case let .unreadable(raw):
            raw
        }
    }

    private var linkTarget: String? {
        guard case let .text(value) = property.value,
              let match = value.trimmingCharacters(in: .whitespaces).wholeMatch(of: /\[\[([^\]|#]+)(?:#[^\]|]*)?(?:\|([^\]]*))?\]\]/)
        else {
            return nil
        }

        return String(match.output.2 ?? match.output.1)
    }

    // MARK: - Actions

    private func startEditing() {
        isEditing = true
    }
}
