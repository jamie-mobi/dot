//
//  WindowTitleUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 27/10/2026.
//

public enum WindowTitleUseCase {
    public static func title(packName: String, openNote: NotePath?) -> String {
        openNote?.name ?? packName
    }

    public static func subtitle(packName: String, openNote: NotePath?) -> String {
        guard let openNote else {
            return ""
        }

        let folder = openNote.parent
        return folder.isRoot ? packName : "\(packName)/\(folder.rawValue)"
    }
}
