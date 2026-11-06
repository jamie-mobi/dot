//
//  StubPackAccess.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation
@testable import DotCore

struct StubPackAccess: PackAccessGranting {
    // MARK: - Stored

    let resolvesBookmarks: Bool
    let resolvesStale: Bool

    // MARK: - Init

    init(resolvesBookmarks: Bool = true, resolvesStale: Bool = false) {
        self.resolvesBookmarks = resolvesBookmarks
        self.resolvesStale = resolvesStale
    }

    // MARK: - PackAccessGranting

    func bookmark(for folderURL: URL) throws(PackError) -> Data {
        Data(folderURL.path.utf8)
    }

    func resolve(bookmark: Data) throws(PackError) -> ResolvedPackBookmark {
        guard resolvesBookmarks else {
            throw .packMissing
        }

        return ResolvedPackBookmark(folderURL: URL(filePath: String(decoding: bookmark, as: UTF8.self)), isStale: resolvesStale)
    }

    func beginAccess(to folderURL: URL) -> Bool {
        true
    }

    func endAccess(to folderURL: URL) {}

    func createPackFolder(at folderURL: URL) throws(PackError) {}
}
