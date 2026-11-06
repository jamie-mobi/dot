//
//  LaunchArguments.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import AppKit
import DotCore

struct LaunchArguments {
    // MARK: - Constants

    private enum Constants {
        static let packPath = "-DotPackPath"
        static let defaultsSuite = "-DotDefaultsSuite"
        static let openNote = "-DotOpenNote"
        static let appearance = "-DotAppearance"
        static let quickOpen = "-DotQuickOpen"
        static let typeText = "-DotTypeText"
        static let indexFolder = "-DotIndexFolder"
        static let search = "-DotSearch"
        static let snapshot = "-DotSnapshot"
        static let readingView = "-DotReadingView"
        static let editAsYAML = "-DotEditAsYAML"
        static let dailyNote = "-DotDailyNote"
        static let templates = "-DotTemplates"
        static let rename = "-DotRename"
        static let move = "-DotMove"
        static let delete = "-DotDelete"
        static let palette = "-DotCommandPalette"
        static let tabs = "-DotTabs"
        static let split = "-DotSplit"
        static let splitShare = "-DotSplitShare"
        static let hideInspector = "-DotHideInspector"
        static let settings = "-DotSettings"
        static let shortcutState = "-DotShortcutState"
        static let newWindow = "-DotNewWindow"
        static let restoreState = "-DotRestoreState"
        static let recentPacks = "-DotRecentPacks"
    }

    // MARK: - Stored

    let packURL: URL?
    let defaultsSuite: String?
    let openNote: NotePath?
    let appearance: String?
    let quickOpen: String?
    let typeText: String?
    let indexFolderURL: URL?
    let search: String?
    let snapshotURL: URL?
    let isReadingView: Bool
    let editsAsYAML: Bool
    let opensDailyNote: Bool
    let showsTemplates: Bool
    let renaming: NotePath?
    let moving: NotePath?
    let deleting: NotePath?
    let showsCommandPalette: Bool
    let extraTabs: [NotePath]
    let splitNote: NotePath?
    let splitShare: Double?
    let hidesInspector: Bool
    let settingsTab: String?
    let shortcutState: String?
    let opensNewWindow: Bool
    let forcesRestore: Bool
    let recentPackURLs: [URL]

    // MARK: - Derived

    var request: LaunchRequest {
        #if DEBUG
            let typed = typeText
            let recentPacks = recentPackURLs
        #else
            let typed: String? = nil
            let recentPacks: [URL] = []
        #endif
        return LaunchRequest(note: openNote, quickOpen: quickOpen, search: search, typeText: typed, isReadingView: isReadingView, editsAsYAML: editsAsYAML, opensDailyNote: opensDailyNote, showsTemplates: showsTemplates, renaming: renaming, moving: moving, deleting: deleting, showsCommandPalette: showsCommandPalette, extraTabs: extraTabs, splitNote: splitNote, splitShare: splitShare, hidesInspector: hidesInspector, settingsTab: settingsTab, shortcutState: shortcutState, opensNewWindow: opensNewWindow, recentPacks: recentPacks)
    }

    var restoresState: Bool {
        packURL == nil || forcesRestore
    }

    var appearanceName: NSAppearance.Name? {
        switch appearance {
        case "light":
            .aqua
        case "dark":
            .darkAqua
        default:
            nil
        }
    }

    // MARK: - Init

    init(_ arguments: [String]) {
        packURL = Self.value(after: Constants.packPath, in: arguments).map { URL(filePath: $0, directoryHint: .isDirectory) }
        defaultsSuite = Self.value(after: Constants.defaultsSuite, in: arguments)
        openNote = Self.value(after: Constants.openNote, in: arguments).map(NotePath.init)
        appearance = Self.value(after: Constants.appearance, in: arguments)
        quickOpen = Self.value(after: Constants.quickOpen, in: arguments)
        typeText = Self.value(after: Constants.typeText, in: arguments)
        search = Self.value(after: Constants.search, in: arguments)
        isReadingView = arguments.contains(Constants.readingView)
        editsAsYAML = arguments.contains(Constants.editAsYAML)
        opensDailyNote = arguments.contains(Constants.dailyNote)
        showsTemplates = arguments.contains(Constants.templates)
        renaming = Self.value(after: Constants.rename, in: arguments).map(NotePath.init)
        moving = Self.value(after: Constants.move, in: arguments).map(NotePath.init)
        deleting = Self.value(after: Constants.delete, in: arguments).map(NotePath.init)
        showsCommandPalette = arguments.contains(Constants.palette)
        extraTabs = (Self.value(after: Constants.tabs, in: arguments) ?? "").split(separator: ",").map { NotePath(String($0)) }
        opensNewWindow = arguments.contains(Constants.newWindow)
        forcesRestore = arguments.contains(Constants.restoreState)
        recentPackURLs = (Self.value(after: Constants.recentPacks, in: arguments) ?? "").split(separator: ",").map { URL(filePath: String($0), directoryHint: .isDirectory) }
        settingsTab = Self.value(after: Constants.settings, in: arguments)
        shortcutState = Self.value(after: Constants.shortcutState, in: arguments)
        splitNote = Self.value(after: Constants.split, in: arguments).map(NotePath.init)
        splitShare = Self.value(after: Constants.splitShare, in: arguments).flatMap(Double.init)
        hidesInspector = arguments.contains(Constants.hideInspector)
        snapshotURL = Self.value(after: Constants.snapshot, in: arguments).map { URL(filePath: $0) }
        indexFolderURL = Self.value(after: Constants.indexFolder, in: arguments).map { URL(filePath: $0, directoryHint: .isDirectory) }
    }

    // MARK: - Private

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }

        return arguments[index + 1]
    }
}
