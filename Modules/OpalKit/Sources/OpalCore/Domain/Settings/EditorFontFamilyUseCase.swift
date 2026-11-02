//
//  EditorFontFamilyUseCase.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

public enum EditorFontFamilyUseCase {
    // MARK: - Resolve

    public static func family(saved: String, installed: Set<String>) -> EditorFontFamily {
        guard saved.isEmpty == false else {
            return .none
        }

        return installed.contains(saved) ? .installed(saved) : .missing(saved)
    }

    // MARK: - List

    public static func choices(from available: [String]) -> [String] {
        Array(Set(available))
            .filter { $0.hasPrefix(".") == false }
            .sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
}
