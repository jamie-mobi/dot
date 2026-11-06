//
//  OpenNoteUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import Foundation

public enum OpenNoteUseCase {
    // MARK: - Constants

    private enum Constants {
        static let noteExtension = "md"
        static let separator = "/"
    }

    // MARK: - Locate

    public static func path(of fileURL: URL, in rootURL: URL) -> NotePath? {
        guard fileURL.pathExtension.lowercased() == Constants.noteExtension else {
            return nil
        }

        let root = OpenPackUseCase.normalized(rootURL)
        let file = OpenPackUseCase.normalized(fileURL)
        let prefix = root + Constants.separator
        guard file.hasPrefix(prefix) else {
            return nil
        }

        let relative = String(file.dropFirst(prefix.count))
        guard relative.isEmpty == false, relative.split(separator: Constants.separator).contains(where: { $0.hasPrefix(".") }) == false else {
            return nil
        }

        return NotePath(relative)
    }

    public static func locate(_ fileURL: URL, roots: [UUID: URL], preferring window: UUID?) -> NoteLocation? {
        if let window, let root = roots[window], let path = path(of: fileURL, in: root) {
            return NoteLocation(window: window, path: path)
        }

        return roots
            .compactMap { id, root in path(of: fileURL, in: root).map { (NoteLocation(window: id, path: $0), root) } }
            .max { OpenPackUseCase.normalized($0.1).count < OpenPackUseCase.normalized($1.1).count }?
            .0
    }
}
