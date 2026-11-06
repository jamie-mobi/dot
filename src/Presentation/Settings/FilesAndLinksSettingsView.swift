//
//  FilesAndLinksSettingsView.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import DotCore
import SwiftUI

struct FilesAndLinksSettingsView: View {
    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - View

    var body: some View {
        let pack = settings.packSettings
        Form {
            Section {
                PackSettingRow(title: String(localized: "Where new Notes go"), isSetByPack: pack.newFileLocation != nil) {
                    Picker(String(localized: "Where new Notes go"), selection: settings.binding(\.newFileLocation, packValue: pack.newFileLocation)) {
                        ForEach(NewFileLocation.allCases, id: \.self) { location in
                            Text(title(of: location)).tag(location)
                        }
                    }
                }
                if (pack.newFileLocation ?? settings.settings.newFileLocation) == .folder {
                    PackSettingRow(title: String(localized: "Folder for new Notes"), isSetByPack: pack.newFileFolderPath != nil) {
                        TextField(String(localized: "Folder for new Notes"), text: settings.binding(\.newFileFolderPath, packValue: pack.newFileFolderPath))
                    }
                }
                PackSettingRow(title: String(localized: "Attachment Folder"), isSetByPack: pack.attachmentFolderPath != nil) {
                    TextField(String(localized: "Attachment Folder"), text: settings.binding(\.attachmentFolderPath, packValue: pack.attachmentFolderPath))
                        .help(String(localized: "“/” is the Pack root, and “./” is the Folder of the Note"))
                }
            }

            Section {
                Toggle(isOn: settings.binding(\.useMarkdownLinks, packValue: pack.useMarkdownLinks)) {
                    Text(String(localized: "Use Markdown Links"))
                    Text(pack.useMarkdownLinks == nil
                        ? String(localized: "Write [text](Note.md) instead of [[Note]].")
                        : String(localized: "Write [text](Note.md) instead of [[Note]]. Set by this Pack's Obsidian settings."))
                }
                .disabled(pack.useMarkdownLinks != nil)

                Picker(
                    String(localized: "Update Links when a Note or Folder is renamed or moved"),
                    selection: settings.binding(\.linkUpdate, packValue: pack.alwaysUpdateLinks.map { $0 ? .always : .ask })
                ) {
                    ForEach(LinkUpdate.allCases, id: \.self) { choice in
                        Text(title(of: choice)).tag(choice)
                    }
                }
                .disabled(pack.alwaysUpdateLinks != nil)
            } footer: {
                if settings.isPackOpen == false {
                    Text(String(localized: "Open a Pack to see its Obsidian settings."))
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Titles

    private func title(of location: NewFileLocation) -> String {
        switch location {
        case .root:
            String(localized: "Pack Folder")
        case .current:
            String(localized: "Same Folder as current Note")
        case .folder:
            String(localized: "In this Folder")
        }
    }

    private func title(of choice: LinkUpdate) -> String {
        switch choice {
        case .ask:
            String(localized: "Ask")
        case .always:
            String(localized: "Always")
        case .never:
            String(localized: "Never")
        }
    }
}
