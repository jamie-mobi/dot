//
//  ShortcutRecordingModifier.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import AppKit
import SwiftUI

struct ShortcutRecordingModifier: ViewModifier {
    // MARK: - Input

    let isActive: Bool
    let onKey: (NSEvent) -> Void

    // MARK: - State

    @State private var monitor: Any?

    // MARK: - View

    func body(content: Content) -> some View {
        content
            .onChange(of: isActive, initial: true) { _, isActive in
                stop()
                if isActive {
                    start()
                }
            }
            .onDisappear(perform: stop)
    }

    // MARK: - Monitor

    private func start() {
        let onKey = onKey
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                onKey(event)
            }
            return nil
        }
    }

    private func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }
}

extension View {
    func recordsShortcut(isActive: Bool, onKey: @escaping (NSEvent) -> Void) -> some View {
        modifier(ShortcutRecordingModifier(isActive: isActive, onKey: onKey))
    }
}
