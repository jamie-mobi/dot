//
//  FolderColourUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum FolderColourUseCase {
    // MARK: - Lookup

    public static func colour(for path: NotePath, in colours: [NotePath: FolderColour]) -> FolderColour? {
        var components = path.components
        while components.isEmpty == false {
            if let colour = colours[NotePath(components.joined(separator: "/"))] {
                return colour
            }
            components.removeLast()
        }
        return nil
    }

    // MARK: - Changes

    public static func moving(_ colours: [NotePath: FolderColour], from old: NotePath, to new: NotePath) -> [NotePath: FolderColour] {
        Dictionary(uniqueKeysWithValues: colours.map { path, colour in
            (path.components.starts(with: old.components) ? path.replacingPrefix(old, with: new) : path, colour)
        })
    }

    public static func forgetting(_ path: NotePath, in colours: [NotePath: FolderColour]) -> [NotePath: FolderColour] {
        colours.filter { $0.key.components.starts(with: path.components) == false }
    }
}
