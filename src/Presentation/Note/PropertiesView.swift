//
//  PropertiesView.swift
//  Dot
//
//  Created by Jamie Le Souef on 28/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct PropertiesView: View {
    // MARK: - Environment

    @Environment(\.navigationService) private var navigation
    @Environment(\.indexService) private var index

    // MARK: - Input

    let document: NoteDocument
    let frontmatter: Frontmatter
    let pane: Int

    // MARK: - State

    @State private var newName = ""
    @State private var isAdding = false
    @State private var isFolded = false
    @FocusState private var isNameFocused: Bool

    // MARK: - View

    var body: some View {
        VStack(spacing: AppSpacing.tiny) {
            header

            if isFolded == false {
                if frontmatter.isReadable == false {
                    Text(String(localized: "Some of this frontmatter is not in a form Dot can show here. Edit it as YAML; Dot leaves it as it is."))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.medium)
                }

                ForEach(frontmatter.properties) { property in
                    PropertyRow(document: document, property: property, type: document.type(of: property))
                }

                addRow
            }
        }
        .padding(AppSpacing.xsmall)
        .background(AppColor.fill, in: RoundedRectangle(cornerRadius: AppRadius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .stroke(AppColor.line)
        }
        .task(id: index.revision) {
            await document.refreshPropertyTypes()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                isFolded.toggle()
            } label: {
                Label(String(localized: "Properties"), systemImage: isFolded ? "chevron.right" : "chevron.down")
                    .foregroundStyle(AppColor.secondaryText)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(isFolded ? String(localized: "Show the Properties") : String(localized: "Hide the Properties"))

            Spacer()

            if isShowingYAML {
                Button(String(localized: "Hide YAML")) {
                    navigation.foldFrontmatter(of: document.path)
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.accent)
                .help(String(localized: "Fold the frontmatter back into the Properties line"))
            } else {
                Button(String(localized: "Edit as YAML"), action: editAsYAML)
                    .buttonStyle(.plain)
                    .foregroundStyle(AppColor.accent)
                    .help(String(localized: "Show the frontmatter in the Editor"))
            }
        }
        .font(AppFont.caption)
        .padding(.horizontal, AppSpacing.medium)
        .frame(height: EditorMetrics.propertyRowHeight)
    }

    // MARK: - Add

    private var addRow: some View {
        HStack {
            if isAdding {
                Image(systemName: "plus")
                    .foregroundStyle(AppColor.quietText)
                TextField(String(localized: "Property name"), text: $newName)
                    .textFieldStyle(.plain)
                    .focused($isNameFocused)
                    .onSubmit(add)
                    .onExitCommand { isAdding = false }
                    .onAppear { isNameFocused = true }
            } else {
                Button(String(localized: "Add Property"), systemImage: "plus") {
                    isAdding = true
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColor.quietText)
            }
            Spacer()
        }
        .font(AppFont.uiBody)
        .padding(.horizontal, AppSpacing.medium)
        .frame(height: EditorMetrics.propertyRowHeight)
    }

    // MARK: - Derived

    private var isShowingYAML: Bool {
        navigation.isReadingView == false && navigation.unfoldedFrontmatter.contains(document.path)
    }

    // MARK: - Intent

    private func add() {
        document.addProperty(named: newName)
        newName = ""
        isAdding = false
    }

    private func editAsYAML() {
        navigation.unfoldFrontmatter(of: document.path)
        navigation.isReadingView = false
        Task {
            await navigation.focusPane(pane)
            await navigation.open(document.path, line: 1)
        }
    }
}
