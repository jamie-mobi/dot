//
//  VaultPanels.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import AppKit
import UniformTypeIdentifiers

@MainActor
enum VaultPanels {
    // MARK: - Panels

    static func chooseVaultFolder() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = String(localized: "Open Vault")
        panel.message = String(localized: "Choose a folder of Markdown files. An Obsidian Vault works as it is.")
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseNewVaultFolder() -> URL? {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = String(localized: "My Vault")
        panel.prompt = String(localized: "Create Vault")
        panel.message = String(localized: "Name the folder for your new Vault.")
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseNoteFile() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "md") ?? .plainText]
        panel.prompt = String(localized: "Open Note")
        panel.message = String(localized: "Choose a Markdown Note.")
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseVaultFolder(holding note: URL) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = note.deletingLastPathComponent()
        panel.prompt = String(localized: "Open Vault")
        panel.message = String(localized: "“\(note.lastPathComponent)” is not in an open Vault. Choose the Vault folder that holds it.")
        return panel.runModal() == .OK ? panel.url : nil
    }

    static func explainNoteOutsideVault(note: URL, folder: URL) {
        let alert = NSAlert()
        alert.messageText = String(localized: "“\(note.lastPathComponent)” Is Not in “\(folder.lastPathComponent)”")
        alert.informativeText = String(localized: "Choose the folder that holds the Note, or one of the folders above it.")
        alert.runModal()
    }
}
