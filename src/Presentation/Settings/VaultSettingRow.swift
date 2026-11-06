//
//  VaultSettingRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import SwiftUI

struct VaultSettingRow<Control: View>: View {
    // MARK: - Input

    let title: String
    let isSetByVault: Bool
    @ViewBuilder let control: Control

    // MARK: - View

    var body: some View {
        LabeledContent {
            control
                .labelsHidden()
                .disabled(isSetByVault)
        } label: {
            Text(title)
            if isSetByVault {
                VaultSettingCaption()
            }
        }
    }
}
