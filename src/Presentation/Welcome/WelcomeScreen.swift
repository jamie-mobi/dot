//
//  WelcomeScreen.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

struct WelcomeScreen: View {
    // MARK: - Input

    let message: String?
    var recents: [RecentPack] = []
    var onOpen: () -> Void = {}
    var onCreate: () -> Void = {}
    var onChoose: (RecentPack) -> Void = { _ in }
    var onRemove: (RecentPack) -> Void = { _ in }

    // MARK: - View

    var body: some View {
        HStack(spacing: 0) {
            hero
            RecentPacksView(packs: recents, onOpen: onChoose, onRemove: onRemove)
                .frame(width: EditorMetrics.welcomeRecentWidth)
                .padding(AppSpacing.small)
        }
        .frame(width: EditorMetrics.welcomeWidth, height: EditorMetrics.welcomeHeight)
        .toolbar(removing: .title)
        .containerBackground(.thinMaterial, for: .window)
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 0) {
            WelcomeIconView()
                .padding(.bottom, AppSpacing.large)

            Text(String(localized: "Welcome to Dot"))
                .font(AppFont.welcomeTitle)
                .foregroundStyle(AppColor.text)
                .padding(.bottom, AppSpacing.small)

            Text(String(localized: "Open a folder of Markdown files to start writing. An Obsidian Vault works as it is."))
                .font(AppFont.welcomeBody)
                .foregroundStyle(AppColor.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: EditorMetrics.welcomeTextWidth)
                .padding(.bottom, AppSpacing.large)

            if let message {
                Label(message, systemImage: "exclamationmark.triangle")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: EditorMetrics.welcomeTextWidth)
                    .padding(.bottom, AppSpacing.regular)
            }

            VStack(spacing: AppSpacing.medium) {
                Button(action: onOpen) {
                    Text(String(localized: "Open Pack…"))
                        .frame(width: EditorMetrics.welcomeButtonWidth)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)

                Button(action: onCreate) {
                    Text(String(localized: "Create Pack…"))
                        .frame(width: EditorMetrics.welcomeButtonWidth)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
            .buttonBorderShape(.capsule)
        }
        .padding(.horizontal, AppSpacing.wide)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
    #Preview {
        WelcomeScreen(message: nil)
    }
#endif
