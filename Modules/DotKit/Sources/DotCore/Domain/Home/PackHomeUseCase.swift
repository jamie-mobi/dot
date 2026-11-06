//
//  PackHomeUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Foundation

public enum PackHomeUseCase {
    // MARK: - Constants

    public static let recentCount = 6
    public static let notesPerGroup = 3
    public static let groupLimit = 8

    // MARK: - Layout

    public static func layout(
        stamps: [NotePath: FileStamp],
        recentCount: Int = recentCount,
        notesPerGroup: Int = notesPerGroup,
        groupLimit: Int = groupLimit
    ) -> PackHomeLayout {
        let newestFirst = stamps.sorted { lhs, rhs in
            lhs.value.modified == rhs.value.modified
                ? lhs.key.rawValue < rhs.key.rawValue
                : lhs.value.modified > rhs.value.modified
        }.map(\.key)

        var byFolder: [NotePath: [NotePath]] = [:]
        var folderOrder: [NotePath] = []
        for path in newestFirst {
            guard path.components.count > 1, let top = path.components.first else {
                continue
            }

            let folder = NotePath(components: [top])
            if byFolder[folder] == nil {
                folderOrder.append(folder)
            }
            byFolder[folder, default: []].append(path)
        }

        let groups = folderOrder.prefix(groupLimit).map { folder in
            let notes = byFolder[folder] ?? []
            return PackHomeGroup(folder: folder, noteCount: notes.count, notes: Array(notes.prefix(notesPerGroup)))
        }
        return PackHomeLayout(noteCount: newestFirst.count, recent: Array(newestFirst.prefix(recentCount)), groups: groups)
    }
}
