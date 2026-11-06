//
//  AttributedString+Dot.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

import DotCore
import DotDesign
import SwiftUI

extension AttributedString {
    // MARK: - Highlight

    func highlighting(_ term: String, background: Color) -> AttributedString {
        var result = self
        for range in ranges(of: term) {
            result[range].backgroundColor = background
            result[range].foregroundColor = AppColor.text
        }
        return result
    }

    func highlighting(_ term: String, foreground: Color) -> AttributedString {
        var result = self
        for range in ranges(of: term) {
            result[range].foregroundColor = foreground
        }
        return result
    }

    static func highlighting(_ spans: [TextSpan], in text: String, background: Color) -> AttributedString {
        var result = AttributedString(text)
        let utf16 = text.utf16
        for span in spans {
            guard span.upperBound <= utf16.count,
                  let start = String.Index(utf16.index(utf16.startIndex, offsetBy: span.location), within: text),
                  let end = String.Index(utf16.index(utf16.startIndex, offsetBy: span.upperBound), within: text),
                  let lower = AttributedString.Index(start, within: result),
                  let upper = AttributedString.Index(end, within: result)
            else {
                continue
            }
            result[lower ..< upper].backgroundColor = background
            result[lower ..< upper].foregroundColor = AppColor.text
        }
        return result
    }

    // MARK: - Ranges

    private func ranges(of term: String) -> [Range<AttributedString.Index>] {
        guard term.isEmpty == false else {
            return []
        }

        var found: [Range<AttributedString.Index>] = []
        var start = startIndex
        while let range = self[start...].range(of: term, options: .caseInsensitive) {
            found.append(range)
            start = range.upperBound
        }
        return found
    }
}
