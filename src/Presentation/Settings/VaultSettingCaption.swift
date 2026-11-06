//
//  VaultSettingCaption.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalDesign
import SwiftUI

struct VaultSettingCaption: View {
    // MARK: - View

    var body: some View {
        Text(String(localized: "Set by this Vault's Obsidian settings"))
            .font(AppFont.caption)
            .foregroundStyle(AppColor.quietText)
    }
}
