//
//  FolderColourStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public protocol FolderColourStoring: Sendable {
    func folderColours(forPackAt rootURL: URL) async -> [NotePath: FolderColour]
    func setFolderColours(_ colours: [NotePath: FolderColour], forPackAt rootURL: URL) async
}
