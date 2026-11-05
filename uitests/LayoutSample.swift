//
//  LayoutSample.swift
//  Opal
//
//  Created by Jamie Le Souef on 05/11/2026.
//

import CoreGraphics

struct LayoutSample {
    // MARK: - Stored

    let key: String
    let tick: Int
    let window: CGRect
    let editor: CGRect
    let text: CGRect
    let properties: CGRect
    let inspector: CGRect
    let picker: CGRect
    let isEdited: Bool

    // MARK: - Derived

    var line: String {
        "\(key)#\(tick) edited=\(isEdited) window=\(Self.format(window)) editor=\(Self.format(editor)) text=\(Self.format(text)) properties=\(Self.format(properties)) inspector=\(Self.format(inspector)) picker=\(Self.format(picker))"
    }

    // MARK: - Private

    private static func format(_ rect: CGRect) -> String {
        guard rect.isNull == false else {
            return "none"
        }

        return "(\(Int(rect.minX)),\(Int(rect.minY)) \(Int(rect.width))x\(Int(rect.height)))"
    }
}
