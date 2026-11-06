//
//  SettingsUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

public enum SettingsUseCase {
    // MARK: - Effective

    public static func appSettings(_ dot: DotSettings, pack: PackSettings) -> ObsidianAppSettings {
        ObsidianAppSettings(
            newFileLocation: pack.newFileLocation ?? dot.newFileLocation,
            newFileFolderPath: pack.newFileFolderPath ?? dot.newFileFolderPath,
            attachmentFolderPath: pack.attachmentFolderPath ?? dot.attachmentFolderPath,
            useMarkdownLinks: pack.useMarkdownLinks ?? dot.useMarkdownLinks,
            newLinkFormat: pack.newLinkFormat ?? ObsidianAppSettings.defaults.newLinkFormat
        )
    }

    public static func dailyNoteSettings(_ dot: DotSettings, pack: PackSettings) -> DailyNoteSettings {
        DailyNoteSettings(
            folder: pack.dailyFolder ?? dot.dailyFolder,
            format: pack.dailyFormat ?? (dot.dailyFormat.isEmpty ? DailyNoteSettings.defaults.format : dot.dailyFormat),
            template: pack.dailyTemplate ?? dot.dailyTemplate
        )
    }

    public static func linkUpdate(_ dot: DotSettings, pack: PackSettings) -> LinkUpdate {
        pack.alwaysUpdateLinks.map { $0 ? .always : .ask } ?? dot.linkUpdate
    }
}
