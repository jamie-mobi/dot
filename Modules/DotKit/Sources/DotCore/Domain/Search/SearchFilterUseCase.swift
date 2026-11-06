//
//  SearchFilterUseCase.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum SearchFilterUseCase {
    // MARK: - Constants

    private enum Constants {
        static let pathPrefix = "path:"
        static let tagPrefix = "tag:"
    }

    // MARK: - Read

    public static func folder(in text: String) -> String? {
        SearchQueryUseCase.parse(text).paths.first
    }

    public static func tag(in text: String) -> String? {
        SearchQueryUseCase.parse(text).tags.first
    }

    // MARK: - Write

    public static func setting(folder: String?, in text: String) -> String {
        replacing(Constants.pathPrefix, with: folder.map { Constants.pathPrefix + quoted($0) }, in: text)
    }

    public static func setting(tag: String?, in text: String) -> String {
        replacing(Constants.tagPrefix, with: tag.map { Constants.tagPrefix + "#" + quoted($0) }, in: text)
    }

    // MARK: - Private

    private static func replacing(_ prefix: String, with filter: String?, in text: String) -> String {
        let kept = tokens(in: text).filter { $0.lowercased().hasPrefix(prefix) == false }
        return (kept + [filter].compactMap(\.self)).joined(separator: " ")
    }

    private static func quoted(_ value: String) -> String {
        value.contains(where: \.isWhitespace) ? "\"\(value)\"" : value
    }

    private static func tokens(in text: String) -> [String] {
        var tokens: [String] = []
        var current = ""
        var inQuotes = false
        for character in text {
            if character == "\"" {
                inQuotes.toggle()
                current.append(character)
            } else if character.isWhitespace, inQuotes == false {
                if current.isEmpty == false {
                    tokens.append(current)
                }
                current = ""
            } else {
                current.append(character)
            }
        }
        if current.isEmpty == false {
            tokens.append(current)
        }
        return tokens
    }
}
