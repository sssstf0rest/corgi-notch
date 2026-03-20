//
//  CorgiNotchApp.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 25/02/25.
//

import SwiftUI
import SwiftData
import Sparkle

@main
struct CorgiNotchApp: App {
    
    @NSApplicationDelegateAdaptor(CorgiAppDelegate.self) var corgiAppDelegate
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    
    @StateObject private var updaterViewModel: UpdaterViewModel = .shared
    
    @ObservedObject private var appDefaults = AppDefaults.shared
    
    @State private var isMenuShown: Bool = true
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error)"
            )
        }
    }()
    
    init() {
        self._isMenuShown = .init(
            initialValue: self.appDefaults.showMenuIcon
        )
    }

    var body: some Scene {
        MenuBarExtra(
            isInserted: $isMenuShown,
            content: {
                Text("CorgiNotch")
                
                NotchOptionsView()
            }
        ) {
            CorgiNotch.Assets.iconMenuBar
                .renderingMode(.template)
        }
        .onChange(
            of: appDefaults.showMenuIcon
        ) { oldVal, newVal in
            if oldVal != newVal {
                isMenuShown = newVal
            }
        }
        
        Settings {
            CorgiSettingsView()
                .modelContainer(sharedModelContainer)
        }
        .windowResizability(.contentSize)
    }
}
