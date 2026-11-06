//
//  DailyNoteSettingsView.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import DotCore
import SwiftUI

struct DailyNoteSettingsView: View {
    // MARK: - Environment

    @Environment(\.settingsService) private var settings

    // MARK: - View

    var body: some View {
        let pack = settings.packSettings
        let format = pack.dailyFormat ?? settings.settings.dailyFormat
        Form {
            Section {
                PackSettingRow(title: String(localized: "Folder"), isSetByPack: pack.dailyFolder != nil) {
                    TextField(String(localized: "Folder"), text: settings.binding(\.dailyFolder, packValue: pack.dailyFolder), prompt: Text(String(localized: "Pack root")))
                }
                PackSettingRow(title: String(localized: "Date format"), isSetByPack: pack.dailyFormat != nil) {
                    TextField(String(localized: "Date format"), text: settings.binding(\.dailyFormat, packValue: pack.dailyFormat), prompt: Text(DailyNoteSettings.defaults.format))
                }
                LabeledContent(String(localized: "Today's Note")) {
                    Text(settings.dailyNotePreview(format: format))
                        .textSelection(.enabled)
                }
                PackSettingRow(title: String(localized: "Template"), isSetByPack: pack.dailyTemplate != nil) {
                    TextField(String(localized: "Template"), text: settings.binding(\.dailyTemplate, packValue: pack.dailyTemplate), prompt: Text(String(localized: "No Template")))
                }
            } footer: {
                if settings.isPackOpen == false {
                    Text(String(localized: "Open a Pack to see its Obsidian settings."))
                }
            }
        }
        .formStyle(.grouped)
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
    }
}
