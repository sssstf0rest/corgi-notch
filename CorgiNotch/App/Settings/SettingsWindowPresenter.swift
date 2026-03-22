//
//  SettingsWindowPresenter.swift
//  CorgiNotch
//
//  Created by OpenAI Codex on 22/03/26.
//

import AppKit

@MainActor
enum SettingsWindowPresenter {

    private static let settingsWindowIdentifier = "com_apple_SwiftUI_Settings_window"

    static func showSettings(
        using openSettings: () -> Void
    ) {
        NSApp.setActivationPolicy(.regular)
        openSettings()

        bringSettingsWindowToFront()

        DispatchQueue.main.async {
            bringSettingsWindowToFront()
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.1
        ) {
            bringSettingsWindowToFront()
        }
    }

    static func settingsWindow() -> NSWindow? {
        NSApp.windows.first {
            $0.identifier?.rawValue == settingsWindowIdentifier
        }
    }

    static func bringSettingsWindowToFront() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        guard let window = settingsWindow() else {
            return
        }

        if window.isMiniaturized {
            window.deminiaturize(nil)
        }

        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
