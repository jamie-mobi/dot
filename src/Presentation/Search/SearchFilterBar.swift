//
//  SearchFilterBar.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct SearchFilterBar: View {
    // MARK: - Environment

    @Environment(\.searchService) private var search
    @Environment(\.vaultService) private var vault
    @Environment(\.linkService) private var links

    // MARK: - Input

    let summary: String

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            folderMenu
            tagMenu
            scopeChip
            matchCaseChip
            Spacer()
            Text(summary)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.quietText)
                .monospacedDigit()
                .lineLimit(1)
        }
    }

    // MARK: - Folder

    private var folderMenu: some View {
        let folder = SearchFilterUseCase.folder(in: search.query)
        return Menu {
            Button(String(localized: "All Folders")) {
                search.query = SearchFilterUseCase.setting(folder: nil, in: search.query)
            }
            Divider()
            ForEach(topFolders, id: \.self) { name in
                Button(name) {
                    search.query = SearchFilterUseCase.setting(folder: name, in: search.query)
                }
            }
        } label: {
            SearchFilterChip(title: folder ?? String(localized: "All Folders"), isSelected: folder != nil, hasMenu: true)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    private var topFolders: [String] {
        vault.tree.filter { $0.kind == .folder }.map(\.path.rawValue)
    }

    // MARK: - Tag

    private var tagMenu: some View {
        let tag = SearchFilterUseCase.tag(in: search.query)
        return Menu {
            Button(String(localized: "Any Tag")) {
                search.query = SearchFilterUseCase.setting(tag: nil, in: search.query)
            }
            Divider()
            ForEach(links.map.tags, id: \.name) { node in
                Button("#\(node.name)  \(node.noteCount)") {
                    search.query = SearchFilterUseCase.setting(tag: node.name, in: search.query)
                }
            }
        } label: {
            SearchFilterChip(title: tag.map { "#\($0)" } ?? String(localized: "Any Tag"), isSelected: tag != nil, hasMenu: true)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
    }

    // MARK: - Scope and case

    private var scopeChip: some View {
        Button {
            let all = SearchScope.allCases
            let next = ((all.firstIndex(of: search.options.scope) ?? 0) + 1) % all.count
            search.options.scope = all[next]
        } label: {
            SearchFilterChip(title: search.options.scope.title, isSelected: true)
        }
        .buttonStyle(.plain)
        .help(String(localized: "Click to search the text, the Properties, or both"))
    }

    private var matchCaseChip: some View {
        Button {
            search.options.matchesCase.toggle()
        } label: {
            SearchFilterChip(title: String(localized: "Match Case"), isSelected: search.options.matchesCase)
        }
        .buttonStyle(.plain)
        .help(String(localized: "Show only matches with the same capital and small letters"))
    }
}
