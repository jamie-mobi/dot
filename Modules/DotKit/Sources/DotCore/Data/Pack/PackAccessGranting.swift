//
//  PackAccessGranting.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public protocol PackAccessGranting: Sendable {
    func bookmark(for folderURL: URL) throws(PackError) -> Data
    func resolve(bookmark: Data) throws(PackError) -> ResolvedPackBookmark
    func beginAccess(to folderURL: URL) -> Bool
    func endAccess(to folderURL: URL)
    func createPackFolder(at folderURL: URL) throws(PackError)
}
