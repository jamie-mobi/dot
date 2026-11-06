//
//  AppFont.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import SwiftUI

public enum AppFont {
    // MARK: - Note

    public static let readingTitle = Font.system(size: 36, weight: .bold)
    public static let noteTitle = Font.system(size: 30, weight: .bold)
    public static let readingHeading = Font.system(size: 22, weight: .semibold)
    public static let noteHeading = Font.system(size: 20, weight: .semibold)
    public static let readingBody = Font.system(size: 17)
    public static let noteBody = Font.system(size: 16)

    // MARK: - Interface

    public static let welcomeTitle = Font.system(size: 28, weight: .bold)
    public static let welcomeBody = Font.system(size: 14)
    public static let windowTitle = Font.system(size: 15, weight: .semibold)
    public static let cardTitle = Font.system(size: 14, weight: .semibold)
    public static let panelField = Font.system(size: 17)
    public static let searchField = Font.system(size: 15)
    public static let uiBody = Font.system(size: 13)
    public static let uiEmphasis = Font.system(size: 13, weight: .semibold)
    public static let cardPreview = Font.system(size: 12.5)
    public static let cardPreviewEmphasis = Font.system(size: 12.5, weight: .semibold)
    public static let caption = Font.system(size: 11.5)
    public static let label = Font.system(size: 11, weight: .semibold)
    public static let keyCap = Font.system(size: 11, weight: .medium)
    public static let code = Font.system(size: 12, design: .monospaced)
}
