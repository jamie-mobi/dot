//
//  PackSettingCaption.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct PackSettingCaption: View {
    // MARK: - View

    var body: some View {
        Text(String(localized: "Set by this Pack's Obsidian settings"))
            .font(AppFont.caption)
            .foregroundStyle(AppColor.quietText)
    }
}
