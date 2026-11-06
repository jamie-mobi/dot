//
//  FilesAndLinksSettingsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalCore
import SwiftUI

struct FilesAndLinksSettingsView: View {
    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - View

    var body: some View {
        let vault = settings.vaultSettings
        Form {
            Section {
                VaultSettingRow(title: String(localized: "Where new Notes go"), isSetByVault: vault.newFileLocation != nil) {
                    Picker(String(localized: "Where new Notes go"), selection: settings.binding(\.newFileLocation, vaultValue: vault.newFileLocation)) {
                        ForEach(NewFileLocation.allCases, id: \.self) { location in
                            Text(title(of: location)).tag(location)
                        }
                    }
                }
                if (vault.newFileLocation ?? settings.settings.newFileLocation) == .folder {
                    VaultSettingRow(title: String(localized: "Folder for new Notes"), isSetByVault: vault.newFileFolderPath != nil) {
                        TextField(String(localized: "Folder for new Notes"), text: settings.binding(\.newFileFolderPath, vaultValue: vault.newFileFolderPath))
                    }
                }
                VaultSettingRow(title: String(localized: "Attachment Folder"), isSetByVault: vault.attachmentFolderPath != nil) {
                    TextField(String(localized: "Attachment Folder"), text: settings.binding(\.attachmentFolderPath, vaultValue: vault.attachmentFolderPath))
                        .help(String(localized: "“/” is the Vault root, and “./” is the Folder of the Note"))
                }
            }

            Section {
                Toggle(isOn: settings.binding(\.useMarkdownLinks, vaultValue: vault.useMarkdownLinks)) {
                    Text(String(localized: "Use Markdown Links"))
                    Text(vault.useMarkdownLinks == nil
                        ? String(localized: "Write [text](Note.md) instead of [[Note]].")
                        : String(localized: "Write [text](Note.md) instead of [[Note]]. Set by this Vault's Obsidian settings."))
                }
                .disabled(vault.useMarkdownLinks != nil)

                Picker(
                    String(localized: "Update Links when a Note or Folder is renamed or moved"),
                    selection: settings.binding(\.linkUpdate, vaultValue: vault.alwaysUpdateLinks.map { $0 ? .always : .ask })
                ) {
                    ForEach(LinkUpdate.allCases, id: \.self) { choice in
                        Text(title(of: choice)).tag(choice)
                    }
                }
                .disabled(vault.alwaysUpdateLinks != nil)
            } footer: {
                if settings.isVaultOpen == false {
                    Text(String(localized: "Open a Vault to see its Obsidian settings."))
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
            String(localized: "Vault Folder")
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
