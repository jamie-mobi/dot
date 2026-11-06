//
//  RecentPackRow.swift
//  Dot
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct RecentPackRow: View {
    // MARK: - Input

    let pack: RecentPack
    let isSelected: Bool
    var onOpen: () -> Void = {}
    var onRemove: () -> Void = {}

    // MARK: - View

    var body: some View {
        HStack(spacing: AppSpacing.comfortable) {
            Button(action: onOpen) {
                HStack(spacing: AppSpacing.comfortable) {
                    Image(systemName: "folder")
                        .font(.title2)
                        .foregroundStyle(AppColor.secondaryText)

                    VStack(alignment: .leading, spacing: AppSpacing.tiny) {
                        Text(pack.name)
                            .font(AppFont.uiEmphasis)
                            .foregroundStyle(AppColor.text)
                            .lineLimit(1)
                        Text(pack.isMissing ? String(localized: "Folder not found") : FolderPathUseCase.short(pack.folderURL.path, home: UserHome.path))
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.quietText)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(pack.isMissing)
            .accessibilityHint(pack.isMissing ? "" : String(localized: "Opens this Pack"))

            if pack.isMissing {
                Button(String(localized: "Remove"), action: onRemove)
                    .controlSize(.small)
                    .accessibilityLabel(String(localized: "Remove \(pack.name) from the list"))
            }
        }
        .opacity(pack.isMissing ? AppOpacity.disabled : 1)
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
        .background(isSelected ? AppColor.selection : .clear, in: RoundedRectangle(cornerRadius: AppRadius.inner))
        .contextMenu {
            Button(String(localized: "Remove from List"), action: onRemove)
        }
    }
}
