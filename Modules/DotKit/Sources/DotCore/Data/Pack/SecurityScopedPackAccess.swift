//
//  SecurityScopedPackAccess.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

import Foundation

public final class SecurityScopedPackAccess: PackAccessGranting {
    // MARK: - Init

    public init() {}

    // MARK: - PackAccessGranting

    public func bookmark(for folderURL: URL) throws(PackError) -> Data {
        do {
            return try folderURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            throw .accessDenied
        }
    }

    public func resolve(bookmark: Data) throws(PackError) -> ResolvedPackBookmark {
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            return ResolvedPackBookmark(folderURL: url, isStale: isStale)
        } catch {
            throw .packMissing
        }
    }

    public func beginAccess(to folderURL: URL) -> Bool {
        folderURL.startAccessingSecurityScopedResource()
    }

    public func endAccess(to folderURL: URL) {
        folderURL.stopAccessingSecurityScopedResource()
    }

    public func createPackFolder(at folderURL: URL) throws(PackError) {
        do {
            try FileManager().createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            throw .accessDenied
        }
    }
}
