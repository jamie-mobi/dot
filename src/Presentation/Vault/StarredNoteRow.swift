//
//  StarredNoteRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct StarredNoteRow: View {
    // MARK: - Input

    let path: NotePath
    let onOpen: () -> Void
    let onUnstar: () -> Void

    // MARK: - View

    var body: some View {
        Button(action: onOpen) {
            Label {
                Text(path.name)
                    .lineLimit(1)
            } icon: {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppColor.accent)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .help(path.rawValue)
        .contextMenu {
            Button(String(localized: "Unstar"), action: onUnstar)
        }
    }
}
