//
//  EditorMetrics.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public enum EditorMetrics {
    // MARK: - Note

    public static let maxTextWidth: CGFloat = 720
    public static let noteLineSpacing: CGFloat = 7
    public static let readingLineSpacing: CGFloat = 9
    public static let cardLineSpacing: CGFloat = 4
    public static let propertyNameWidth: CGFloat = 150
    public static let propertyRowHeight: CGFloat = 32
    public static let imagePlaceholderHeight: CGFloat = 170

    // MARK: - Window

    public static let sidebarWidth: CGFloat = 248
    public static let inspectorWidth: CGFloat = 320
    public static let windowMinWidth: CGFloat = 1100
    public static let windowMinHeight: CGFloat = 700
    public static let windowDefaultWidth: CGFloat = 1440
    public static let windowDefaultHeight: CGFloat = 900

    // MARK: - Home

    public static let cardHeight: CGFloat = 212
    public static let cardEdge: CGFloat = 3
    public static let cardFooterHeight: CGFloat = 38
    public static let cardFadeStart: CGFloat = 0.72
    public static let labelDot: CGFloat = 7
    public static let searchBarHeight: CGFloat = 48
    public static let cardColumns = 3

    // MARK: - Search

    public static let resultKindWidth: CGFloat = 58

    // MARK: - Panels

    public static let panelWidth: CGFloat = 640
    public static let panelTopInset: CGFloat = 110
    public static let panelShadowRadius: CGFloat = 35
    public static let panelShadowY: CGFloat = 28
    public static let panelMaxListHeight: CGFloat = 420

    // MARK: - Welcome

    public static let welcomeWidth: CGFloat = 780
    public static let welcomeHeight: CGFloat = 500
    public static let welcomeRecentWidth: CGFloat = 300
    public static let welcomeIcon: CGFloat = 104
    public static let welcomeIconRadius: CGFloat = 24
    public static let welcomeButtonWidth: CGFloat = 240
    public static let welcomeTextWidth: CGFloat = 320

    // MARK: - Settings

    public static let settingsWidth: CGFloat = 640

    // MARK: - Editor text

    public static let fontSize: CGFloat = 16
    public static let textInset: CGFloat = 56
    public static let headingScales: [CGFloat] = [1.875, 1.25, 1.125, 1.06, 1.03, 1]
    public static let readingScale: CGFloat = 1.0625
    public static let readingHeadingScales: [CGFloat] = [2.12, 1.3, 1.15, 1.08, 1.04, 1]
    public static let editorLineHeightMultiple: CGFloat = 1.36
    public static let readingLineHeightRatio: CGFloat = 1.7
    public static let headingLineHeightRatio: CGFloat = 1.18
    public static let codeScale: CGFloat = 0.92
    public static let blockIndent: CGFloat = 14
    public static let blockBarWidth: CGFloat = 3
    public static let listIndent: CGFloat = 20
    public static let readableLineWidth = Double(maxTextWidth)
    public static let pdfEmbedHeight: CGFloat = 480

    // MARK: - Editor panes

    public static let tabMaxWidth: CGFloat = 200
    public static let paneMinWidth: CGFloat = 280
    public static let dividerThickness: CGFloat = 1
    public static let dividerGrabWidth: CGFloat = 9
    public static let dividerStep = 0.05

    // MARK: - Link suggestions

    public static let suggestionRowHeight: CGFloat = 40
    public static let suggestionMaxRows = 7
    public static let suggestionGap: CGFloat = 4
    public static let suggestionWidth: CGFloat = 320

    // MARK: - Lists

    public static let recentNotesShown = 5

    // MARK: - Derived

    public static func headingScale(level: Int) -> CGFloat {
        headingScales[min(max(level, 1), headingScales.count) - 1]
    }

    public static func readingHeadingScale(level: Int) -> CGFloat {
        readingHeadingScales[min(max(level, 1), readingHeadingScales.count) - 1]
    }
}
