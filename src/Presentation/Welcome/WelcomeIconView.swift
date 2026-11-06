//
//  WelcomeIconView.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotDesign
import SwiftUI

struct WelcomeIconView: View {
    // MARK: - View

    var body: some View {
        RoundedRectangle(cornerRadius: EditorMetrics.welcomeIconRadius)
            .fill(LinearGradient(colors: [AppColor.iconTop, AppColor.iconBottom], startPoint: .top, endPoint: .bottom))
            .frame(width: EditorMetrics.welcomeIcon, height: EditorMetrics.welcomeIcon)
            .overlay {
                Image(systemName: "diamond")
                    .font(.largeTitle)
                    .foregroundStyle(AppColor.iconSymbol)
            }
            .shadow(color: AppColor.popoverShadow, radius: AppSpacing.comfortable, y: AppSpacing.medium)
            .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview {
        WelcomeIconView()
            .padding()
    }
#endif
