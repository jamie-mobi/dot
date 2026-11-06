//
//  SettingsStoring.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

public protocol SettingsStoring: Sendable {
    func settings() -> DotSettings
    func setSettings(_ settings: DotSettings)
}
