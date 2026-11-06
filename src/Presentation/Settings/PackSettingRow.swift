//
//  PackSettingRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import SwiftUI

struct PackSettingRow<Control: View>: View {
    // MARK: - Input

    let title: String
    let isSetByPack: Bool
    @ViewBuilder let control: Control

    // MARK: - View

    var body: some View {
        LabeledContent {
            control
                .labelsHidden()
                .disabled(isSetByPack)
        } label: {
            Text(title)
            if isSetByPack {
                PackSettingCaption()
            }
        }
    }
}
