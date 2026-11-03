//
//  StubFolderColourStore.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation
@testable import OpalCore

actor StubFolderColourStore: FolderColourStoring {
    // MARK: - Stored

    private(set) var stored: [URL: [NotePath: FolderColour]] = [:]

    // MARK: - FolderColourStoring

    func folderColours(forVaultAt rootURL: URL) -> [NotePath: FolderColour] {
        stored[rootURL] ?? [:]
    }

    func setFolderColours(_ colours: [NotePath: FolderColour], forVaultAt rootURL: URL) {
        stored[rootURL] = colours
    }
}
