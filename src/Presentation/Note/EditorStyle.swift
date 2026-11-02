//
//  EditorStyle.swift
//  Opal
//
//  Created by Jamie Le Souef on 29/10/2026.
//

import AppKit
import OpalDesign
import SwiftUI

struct EditorStyle: Hashable {
    // MARK: - Constants

    private enum Constants {
        static let regularMemberWeight = 5
    }

    // MARK: - Defaults

    static let defaults = EditorStyle()

    // MARK: - Stored

    var design = EditorFontDesign.system
    var family: String?
    var size = EditorMetrics.fontSize
    var lineSpacing: CGFloat = 1
    var lineWidth: CGFloat = 0
    var checksSpelling = true

    // MARK: - Fonts

    func font(scale: CGFloat = 1, weight: NSFont.Weight = .regular) -> NSFont {
        let base = NSFont.systemFont(ofSize: size * scale, weight: weight)
        if let family {
            return familyFont(family, size: size * scale, weight: weight) ?? base
        }

        guard let descriptor = base.fontDescriptor.withDesign(design.design) else {
            return base
        }

        return NSFont(descriptor: descriptor, size: size * scale) ?? base
    }

    private func familyFont(_ family: String, size: CGFloat, weight: NSFont.Weight) -> NSFont? {
        guard let font = NSFontManager.shared.font(withFamily: family, traits: [], weight: Constants.regularMemberWeight, size: size) else {
            return nil
        }

        return weight >= .semibold ? NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask) : font
    }

    var codeFont: NSFont {
        .monospacedSystemFont(ofSize: size * EditorMetrics.codeScale, weight: .regular)
    }

    // MARK: - Reading view

    var readingFont: Font {
        Font(font())
    }

    var readingCodeFont: Font {
        Font(codeFont)
    }

    var lineHeight: CGFloat {
        NSLayoutManager().defaultLineHeight(for: font()) * lineSpacing
    }

    // MARK: - Paragraphs

    var paragraph: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = lineSpacing
        return style
    }

    var indentedParagraph: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = lineSpacing
        style.firstLineHeadIndent = EditorMetrics.blockIndent
        style.headIndent = EditorMetrics.blockIndent
        return style
    }

    var baseAttributes: [NSAttributedString.Key: Any] {
        [.font: font(), .foregroundColor: AppKitColor.text, .paragraphStyle: paragraph]
    }

    // MARK: - Width

    func horizontalInset(forWidth width: CGFloat) -> CGFloat {
        guard lineWidth > 0 else {
            return EditorMetrics.textInset
        }

        return max(EditorMetrics.textInset, (width - lineWidth) / 2)
    }
}
