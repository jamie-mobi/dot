//
//  RecentVaultRow.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct RecentVaultRow: View {
    // MARK: - Input

    let vault: RecentVault
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
                        Text(vault.name)
                            .font(AppFont.uiEmphasis)
                            .foregroundStyle(AppColor.text)
                            .lineLimit(1)
                        Text(vault.isMissing ? String(localized: "Folder not found") : FolderPathUseCase.short(vault.folderURL.path, home: UserHome.path))
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
            .disabled(vault.isMissing)
            .accessibilityHint(vault.isMissing ? "" : String(localized: "Opens this Vault"))

            if vault.isMissing {
                Button(String(localized: "Remove"), action: onRemove)
                    .controlSize(.small)
                    .accessibilityLabel(String(localized: "Remove \(vault.name) from the list"))
            }
        }
        .opacity(vault.isMissing ? AppOpacity.disabled : 1)
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, AppSpacing.small)
        .background(isSelected ? AppColor.selection : .clear, in: RoundedRectangle(cornerRadius: AppRadius.inner))
        .contextMenu {
            Button(String(localized: "Remove from List"), action: onRemove)
        }
    }
}
