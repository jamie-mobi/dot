//
//  StubSettingsStore.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import Foundation
@testable import DotCore

final class StubSettingsStore: SettingsStoring, @unchecked Sendable {
    // MARK: - Stored

    private(set) var saved: DotSettings?
    private let initial: DotSettings

    // MARK: - Init

    init(_ initial: DotSettings = .defaults) {
        self.initial = initial
    }

    // MARK: - SettingsStoring

    func settings() -> DotSettings {
        saved ?? initial
    }

    func setSettings(_ settings: DotSettings) {
        saved = settings
    }
}
