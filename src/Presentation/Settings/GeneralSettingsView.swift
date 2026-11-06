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
    @Environment(\.tagSuggestionService) private var tagSuggestions

    // MARK: - View

    var body: some View {
        Form {
            Toggle(isOn: settings.binding(\.reopensVaultsAtLaunch)) {
                Text(String(localized: "Reopen Vaults at launch"))
                Text(String(localized: "Opens the windows and Vaults you had open when you last quit."))
            }

            Section {
                Toggle(isOn: settings.binding(\.suggestsTags)) {
                    Label(String(localized: "Suggest Tags"), systemImage: "sparkles")
                    Text(availabilityNote)
                }
                .disabled(tagSuggestions.availability != .available && settings.settings.suggestsTags == false)
            } header: {
                Text(String(localized: "Apple Intelligence"))
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Derived

    private var availabilityNote: String {
        switch tagSuggestions.availability {
        case .available:
            String(localized: "Shows Tags for the open Note under its Properties. Click one to add it. Runs on this Mac; the Note never leaves it.")
        case .deviceNotEligible:
            String(localized: "This Mac does not support Apple Intelligence.")
        case .appleIntelligenceOff:
            String(localized: "Turn on Apple Intelligence in System Settings to use this.")
        case .modelNotReady:
            String(localized: "Apple Intelligence is still getting ready. Try again later.")
        }
    }
}
