//
//  GeneralSettingsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import SwiftUI

struct GeneralSettingsView: View {
    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - View

    var body: some View {
        Form {
            Toggle(isOn: settings.binding(\.reopensVaultsAtLaunch)) {
                Text(String(localized: "Reopen Vaults at launch"))
                Text(String(localized: "Opens the windows and Vaults you had open when you last quit."))
            }
        }
        .formStyle(.grouped)
    }
}
