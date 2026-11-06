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
            Section {
                Picker(String(localized: "Appearance"), selection: $appearance) {
                    ForEach(AppearanceChoice.allCases) { choice in
                        Label(choice.title, systemImage: choice.systemImage).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text(String(localized: "System follows the Appearance set in macOS System Settings."))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
            }

            Section {
                Picker(String(localized: "Accent"), selection: $accent) {
                    ForEach(AppAccent.allCases) { choice in
                        Text(choice.title).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
            } footer: {
                Text(String(localized: "System uses the accent colour set in macOS System Settings."))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
