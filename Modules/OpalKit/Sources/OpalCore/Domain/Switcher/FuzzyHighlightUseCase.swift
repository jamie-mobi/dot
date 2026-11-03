//
//  FuzzyHighlightUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum FuzzyHighlightUseCase {
    // MARK: - Highlight

    public static func marked(_ query: String, in text: String) -> [Int] {
        let needle = Array(query.lowercased().filter { $0.isWhitespace == false })
        guard needle.isEmpty == false else {
            return []
        }

        let letters = Array(text.lowercased())
        if let start = contiguousStart(of: needle, in: letters) {
            return Array(start ..< start + needle.count)
        }

        var marked: [Int] = []
        var next = 0
        for (index, letter) in letters.enumerated() where next < needle.count && letter == needle[next] {
            marked.append(index)
            next += 1
        }
        return next == needle.count ? marked : []
    }

    // MARK: - Private

    private static func contiguousStart(of needle: [Character], in letters: [Character]) -> Int? {
        guard needle.count <= letters.count else {
            return nil
        }

        return (0 ... letters.count - needle.count).first { Array(letters[$0 ..< $0 + needle.count]) == needle }
    }
}
