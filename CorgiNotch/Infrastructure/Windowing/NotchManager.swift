//
//  NotchManager.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 12/03/25.
//

import SwiftUI
import MacroVisionKit

class NotchManager {
    
    static let shared = NotchManager()
    
    var notchDefaults: NotchDefaults = .shared
    
    var windows: [NSScreen: NSWindow] = [:]
    
    private var monitorTask: Task<Void, Never>?
    private var isScreenLocked = false
    
    private init() {
        monitorTask = Task { @MainActor in
            let stream = await FullScreenMonitor.shared.spaceChanges()
            for await spaces in stream {
                self.updateFullScreenStatus(with: spaces)
            }
        }
        
        addListenerForScreenUpdates()
        addLockStateListeners()
    }
    
    deinit {
        monitorTask?.cancel()
        removeListenerForScreenUpdates()
        removeLockStateListeners()
    }
    
    @MainActor
    private func updateFullScreenStatus(with spaces: [MacroVisionKit.FullScreenMonitor.SpaceInfo]) {
        guard notchDefaults.hideOnFullScreen else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.6
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            windows.forEach { $0.value.animator().alphaValue = 1 }
        }
        
        for space in spaces {
            if let screen = FullScreenMonitor.shared.screen(for: space) {
                windows[screen]?.alphaValue = 0
            }
        }
    }
    
    @objc func refreshNotches(
        killAllWindows: Bool = false,
        addToSeparateSpace: Bool = true
    ) {
        
        let shownOnDisplays = Set(notchDefaults.shownOnDisplay.filter { $1 }.keys)
        
        let shouldShowOnScreen: (NSScreen) -> Bool = { [weak self] screen in
            guard let self else { return false }
            
            if self.notchDefaults.notchDisplayVisibility != .custom {
                return true
            }
            
            return shownOnDisplays.contains(screen.localizedName)
        }
        
        windows.forEach { screen, window in
            if killAllWindows || !NSScreen.screens.contains(
                where: { $0 == screen}
            ) || !shouldShowOnScreen(screen) {
                NotchSpaceManager.shared.notchSpace.windows.remove(window)
                window.close()
                
                windows.removeValue(
                    forKey: screen
                )
            }
        }
        
        NSScreen.screens.filter {
            shouldShowOnScreen($0)
        }.forEach { screen in
            var panel: NSWindow! = windows[screen]
            
            if panel == nil {
                let view: NSView = NSHostingView(
                    rootView: NotchView(
                        screen: screen
                    )
                )
                
                panel = CorgiPanel(
                    contentRect: screen.frame,
                    styleMask: [
                        .borderless,
                        .nonactivatingPanel,
                        .utilityWindow,
                        .hudWindow
                    ],
                    backing: .buffered,
                    defer: true
                )
                
                panel.contentView = view
            }

            if let corgiPanel = panel as? CorgiPanel {
                corgiPanel.setShownOnLockScreen(
                    notchDefaults.shownOnLockScreen
                )
            }
            
            NotchSpaceManager.shared.notchSpace.windows.remove(panel)
            
            panel.setFrame(
                screen.frame,
                display: true
            )

            windows[screen] = panel
            
            if addToSeparateSpace && notchDefaults.shownOnLockScreen {
                WindowManager.shared?.moveToLockScreen(panel)
            }
            
            if isScreenLocked && !notchDefaults.shownOnLockScreen {
                panel.orderOut(nil)
            } else {
                panel.orderFrontRegardless()
            }
        }
        
        // Trigger manual update based on current state
        Task { @MainActor in
            let spaces = await FullScreenMonitor.shared.detectFullscreenApps()
            self.updateFullScreenStatus(with: spaces)
        }
    }
    
    func addListenerForScreenUpdates() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshNotches),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    func removeListenerForScreenUpdates() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addLockStateListeners() {
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }
    
    func removeLockStateListeners() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    @objc private func screenLocked() {
        isScreenLocked = true
        
        guard !notchDefaults.shownOnLockScreen else { return }
        
        windows.values.forEach { window in
            window.orderOut(nil)
        }
    }
    
    @objc private func screenUnlocked() {
        let shouldRefresh = isScreenLocked && !notchDefaults.shownOnLockScreen
        isScreenLocked = false
        
        guard shouldRefresh else { return }
        
        refreshNotches()
    }
}
