//
//  AppAccent.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import Synchronization

public enum AppAccent: String, CaseIterable, Identifiable, Sendable {
    case opal
    case system

    // MARK: - Preference

    public static let key = "accent"
    public static let defaultValue = AppAccent.opal

    public static var current: AppAccent {
        get { storage.withLock { $0 } }
        set { storage.withLock { $0 = newValue } }
    }

    private static let storage = Mutex(AppAccent.defaultValue)

    // MARK: - Identifiable

    public var id: String {
        rawValue
    }
}
