//
//  RecentVaultsView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct RecentVaultsView: View {
    // MARK: - Input

    let vaults: [RecentVault]
    var onOpen: (RecentVault) -> Void = { _ in }
    var onRemove: (RecentVault) -> Void = { _ in }

    // MARK: - State

    @State private var hovered: RecentVault.ID?

    // MARK: - View

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.tiny) {
            Text(String(localized: "Recent Vaults"))
                .font(AppFont.label)
                .foregroundStyle(AppColor.quietText)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.small)

            if vaults.isEmpty {
                Text(String(localized: "Vaults you open show here."))
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.quietText)
                    .padding(.horizontal, AppSpacing.medium)
            }

            ScrollView {
                VStack(spacing: AppSpacing.tiny) {
                    ForEach(vaults) { vault in
                        RecentVaultRow(vault: vault, isSelected: vault.id == (hovered ?? vaults.first?.id)) {
                            onOpen(vault)
                        } onRemove: {
                            onRemove(vault)
                        }
                        .onHover { isHovering in
                            hovered = isHovering ? vault.id : nil
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)

            Spacer(minLength: 0)
        }
        .padding(.vertical, AppSpacing.regular)
        .padding(.horizontal, AppSpacing.medium)
        .frame(maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppRadius.panel))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.panel)
                .stroke(AppColor.line)
        }
    }
}
