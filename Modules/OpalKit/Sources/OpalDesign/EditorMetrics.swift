//
//  EditorMetrics.swift
//  Opal
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public enum EditorMetrics {
    public static let fontSize: CGFloat = 16
    public static let textInset: CGFloat = 48
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
    public static let propertyNameWidth: CGFloat = 140
    public static let propertyIconWidth: CGFloat = 18
    public static let shortcutGroupWidth: CGFloat = 40
    public static let tabMaxWidth: CGFloat = 200
    public static let pdfEmbedHeight: CGFloat = 480
    public static let welcomeIconSize: CGFloat = 96
    public static let settingsWidth: CGFloat = 520
    public static let shortcutsListHeight: CGFloat = 480
    public static let suggestionRowHeight: CGFloat = 40
    public static let suggestionMaxRows = 7
    public static let suggestionGap: CGFloat = 4
    public static let narrowLineWidth = 600.0
    public static let readableLineWidth = 720.0
    public static let sidebarMinWidth: CGFloat = 200
    public static let sidebarIdealWidth: CGFloat = 220
    public static let inspectorMinWidth: CGFloat = 220
    public static let inspectorIdealWidth: CGFloat = 260
    public static let inspectorMaxWidth: CGFloat = 420
    public static let paneMinWidth: CGFloat = 280
    public static let dividerThickness: CGFloat = 1
    public static let dividerGrabWidth: CGFloat = 9
    public static let dividerStep = 0.05
    public static let suggestionWidth: CGFloat = 320
    public static let switcherWidth: CGFloat = 760
    public static let switcherHeight: CGFloat = 420
    public static let switcherPreviewWidth: CGFloat = 300
    public static let paletteWidth: CGFloat = 600
    public static let welcomeWidth: CGFloat = 420
    public static let welcomeRecentRowHeight: CGFloat = 44
    public static let welcomeRecentMaxRows = 5
    public static let recentNotesShown = 5
    public static let cardMinWidth: CGFloat = 220
    public static let cardPreviewMinHeight: CGFloat = 76
    public static let cardEdge: CGFloat = 3
    public static let focusRing: CGFloat = 2
    public static let cardShadowRadius: CGFloat = 2
    public static let cardShadowOffset: CGFloat = 1
    public static let homeMaxWidth: CGFloat = 1080
    public static let homeSearchWidth: CGFloat = 520
    public static let labelDotSize: CGFloat = 8
    public static let windowMinWidth: CGFloat = 640
    public static let windowMinHeight: CGFloat = 420
    public static let windowDefaultWidth: CGFloat = 1100
    public static let windowDefaultHeight: CGFloat = 720

    // MARK: - Derived

    public static func headingScale(level: Int) -> CGFloat {
        headingScales[min(max(level, 1), headingScales.count) - 1]
    }

    public static func readingHeadingScale(level: Int) -> CGFloat {
        readingHeadingScales[min(max(level, 1), readingHeadingScales.count) - 1]
    }
}
