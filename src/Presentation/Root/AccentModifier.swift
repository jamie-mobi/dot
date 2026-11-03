//
//  AccentModifier.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalDesign
import SwiftUI

struct AccentModifier: ViewModifier {
    // MARK: - State

    @AppStorage(AppAccent.key) private var accent = AppAccent.defaultValue

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        content
            .tint(tint)
            .onChange(of: accent, initial: true) { _, choice in
                AppAccent.current = choice
                for window in NSApp.windows {
                    window.contentView?.needsDisplay = true
                }
            }
    }

    // MARK: - Private

    private var tint: Color {
        switch accent {
        case .opal:
            Color(nsColor: AppBrandColor.accent)
        case .system:
            Color.accentColor
        }
    }
}

extension View {
    func followsAccent() -> some View {
        modifier(AccentModifier())
    }
}
