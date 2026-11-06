//
//  StubFolderColourStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import DotCore

actor StubFolderColourStore: FolderColourStoring {
    // MARK: - Stored

    private(set) var stored: [URL: [NotePath: FolderColour]] = [:]

    // MARK: - FolderColourStoring

    func folderColours(forPackAt rootURL: URL) -> [NotePath: FolderColour] {
        stored[rootURL] ?? [:]
    }

    func setFolderColours(_ colours: [NotePath: FolderColour], forPackAt rootURL: URL) {
        stored[rootURL] = colours
    }
}
