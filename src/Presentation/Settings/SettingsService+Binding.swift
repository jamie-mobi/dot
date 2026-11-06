//
//  SettingsService+Binding.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import DotCore
import SwiftUI

extension SettingsService {
    // MARK: - Bindings

    func binding<Value>(_ key: WritableKeyPath<DotSettings, Value>, packValue: Value? = nil) -> Binding<Value> {
        Binding {
            packValue ?? self.settings[keyPath: key]
        } set: { newValue in
            self.settings[keyPath: key] = newValue
        }
    }
}
