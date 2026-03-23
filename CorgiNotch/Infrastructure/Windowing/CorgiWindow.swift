//
//  CorgiWindow.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI

class CorgiPanel: NSPanel {

    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: backing,
            defer: flag
        )

        isFloatingPanel = true
        isOpaque = false
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = .clear
        isMovable = false

        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle,
        ]

        canBecomeVisibleWithoutLogin = true
        level = .mainMenu + 1

        hasShadow = false

        // Required for SwiftUI dropDestination to work on non-key panels
        acceptsMouseMovedEvents = true
    }

    func setShownOnLockScreen(_ shownOnLockScreen: Bool) {
        canBecomeVisibleWithoutLogin = shownOnLockScreen
    }

    override var canBecomeKey: Bool {
        // Allow becoming key so SwiftUI drop destinations receive events
        true
    }

    override var canBecomeMain: Bool {
        false
    }

}
