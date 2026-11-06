//
//  VaultOverlayView.swift
//  Opal
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import OpalCore
import OpalDesign
import SwiftUI

struct VaultOverlayView: View {
    // MARK: - Environment

    @Environment(\.navigationService) private var navigation
    @Environment(\.templateService) private var templates

    // MARK: - Derived

    private var overlay: VaultOverlay? {
        if navigation.isQuickSwitcherShown {
            return .quickSwitcher
        }
        if navigation.isCommandPaletteShown {
            return .commandPalette
        }
        if templates.isPickerShown {
            return .templates
        }
        return nil
    }

    // MARK: - View

    var body: some View {
        if let overlay {
            ZStack(alignment: .top) {
                AppColor.scrim
                    .ignoresSafeArea()
                    .onTapGesture(perform: dismiss)
                    .accessibilityHidden(true)

                panel(overlay)
                    .padding(.top, EditorMetrics.panelTopInset)
            }
            .onExitCommand(perform: dismiss)
        }
    }

    // MARK: - Panel

    @ViewBuilder
    private func panel(_ overlay: VaultOverlay) -> some View {
        switch overlay {
        case .quickSwitcher:
            QuickSwitcherView()
        case .commandPalette:
            CommandPaletteView()
        case .templates:
            TemplatePickerView()
        }
    }

    // MARK: - Actions

    private func dismiss() {
        navigation.isQuickSwitcherShown = false
        navigation.isCommandPaletteShown = false
        templates.isPickerShown = false
    }
}
