//
//  AppearanceSettingsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalDesign
import SwiftUI

struct AppearanceSettingsView: View {
    // MARK: - State

    @AppStorage(EditorPreferences.appearanceKey) private var appearance = AppearanceChoice.system
    @AppStorage(AppAccent.key) private var accent = AppAccent.defaultValue

    // MARK: - View

    var body: some View {
        Form {
            Picker(String(localized: "Appearance"), selection: $appearance) {
                ForEach(AppearanceChoice.allCases) { choice in
                    Text(choice.title).tag(choice)
                }
            }
            .pickerStyle(.radioGroup)

            Picker(String(localized: "Accent"), selection: $accent) {
                ForEach(AppAccent.allCases) { choice in
                    Text(choice.title).tag(choice)
                }
            }
            .pickerStyle(.radioGroup)
        }
        .formStyle(.grouped)
    }
}
