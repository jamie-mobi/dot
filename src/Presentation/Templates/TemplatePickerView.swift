//
//  TemplatePickerView.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct TemplatePickerView: View {
    // MARK: - Environment

    @Environment(\.templateService) private var templates

    // MARK: - State

    @State private var query = ""
    @State private var selectedIndex = 0

    // MARK: - View

    var body: some View {
        let matches = self.matches
        CommandPanelView(
            symbol: "doc.on.doc",
            placeholder: String(localized: "Insert a Template"),
            query: $query,
            shortcut: ["⌥", "⌘", "T"],
            hints: [
                KeyHint(keys: "↑↓", title: String(localized: "Move")),
                KeyHint(keys: "↩", title: String(localized: "Insert"))
            ],
            scrollTarget: matches.indices.contains(selectedIndex) ? AnyHashable(matches[selectedIndex]) : nil,
            onMove: { delta in
                selectedIndex = min(max(selectedIndex + delta, 0), max(matches.count - 1, 0))
            },
            onSubmit: insertSelected
        ) {
            if let folder = templates.folder {
                if matches.isEmpty {
                    PanelEmptyRow(
                        title: String(localized: "No Templates"),
                        detail: query.isEmpty
                            ? String(localized: "Add a Note to “\(folder.rawValue)” to use it as a Template.")
                            : String(localized: "No Template matches “\(query)”.")
                    )
                }
                ForEach(Array(matches.enumerated()), id: \.element) { index, template in
                    row(template, folder: folder, isSelected: index == selectedIndex) {
                        selectedIndex = index
                        insertSelected()
                    }
                    .id(template)
                }
            } else {
                PanelEmptyRow(
                    title: String(localized: "No Templates Folder"),
                    detail: String(localized: "Choose a Templates Folder in Obsidian's Templates settings for this Pack.")
                )
            }
        }
        .onChange(of: query) { selectedIndex = 0 }
    }

    // MARK: - Row

    private func row(_ template: NotePath, folder: NotePath, isSelected: Bool, onInsert: @escaping () -> Void) -> some View {
        let subfolder = template.parent.components.dropFirst(folder.components.count).joined(separator: "/")
        return Button(action: onInsert) {
            HStack(spacing: AppSpacing.comfortable) {
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(AppColor.quietText)
                VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                    Text(template.name)
                        .font(AppFont.uiEmphasis)
                        .foregroundStyle(AppColor.text)
                        .lineLimit(1)
                    Text(subfolder.isEmpty ? folder.rawValue : subfolder)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.quietText)
                        .lineLimit(1)
                }
                Spacer()
                if isSelected {
                    KeyCapsView(keys: ["↩"])
                }
            }
            .padding(.horizontal, AppSpacing.comfortable)
            .padding(.vertical, AppSpacing.small)
            .background(isSelected ? AppColor.accentSoft : .clear, in: RoundedRectangle(cornerRadius: AppRadius.inner))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Matching

    private var matches: [NotePath] {
        let needle = query.trimmingCharacters(in: .whitespaces)
        guard needle.isEmpty == false else {
            return templates.templates
        }

        return templates.templates.filter { $0.rawValue.localizedCaseInsensitiveContains(needle) }
    }

    private func insertSelected() {
        let list = matches
        guard list.indices.contains(selectedIndex) else {
            return
        }

        let template = list[selectedIndex]
        Task { await templates.insert(template) }
    }
}
