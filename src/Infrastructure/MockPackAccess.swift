//
//  MockPackAccess.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

#if DEBUG
    import Foundation
    import DotCore

    struct MockPackAccess: PackAccessGranting {
        // MARK: - PackAccessGranting

        func bookmark(for folderURL: URL) throws(PackError) -> Data {
            Data(folderURL.path.utf8)
        }

        func resolve(bookmark: Data) throws(PackError) -> ResolvedPackBookmark {
            ResolvedPackBookmark(folderURL: URL(filePath: String(decoding: bookmark, as: UTF8.self)), isStale: false)
        }

        func beginAccess(to folderURL: URL) -> Bool {
            false
        }

        func endAccess(to folderURL: URL) {}

        func createPackFolder(at folderURL: URL) throws(PackError) {}
    }
#endif
