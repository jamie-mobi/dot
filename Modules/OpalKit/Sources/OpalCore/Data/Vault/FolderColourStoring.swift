//
//  FolderColourStoring.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public protocol FolderColourStoring: Sendable {
    func folderColours(forVaultAt rootURL: URL) async -> [NotePath: FolderColour]
    func setFolderColours(_ colours: [NotePath: FolderColour], forVaultAt rootURL: URL) async
}
