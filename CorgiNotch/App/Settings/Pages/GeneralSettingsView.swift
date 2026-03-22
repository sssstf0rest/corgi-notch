//
//  GeneralSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 27/02/25.
//

import SwiftUI
import LaunchAtLogin

struct GeneralSettingsView: View {

    @StateObject var appDefaults = AppDefaults.shared
    @StateObject var notchDefaults = NotchDefaults.shared

    @State private var isAccessibilityTrusted: Bool = AXIsProcessTrusted()

    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Launch at Login",
                    subtitle: "Automatically start CorgiNotch when you log in",
                    icon: CorgiNotch.Assets.icLaunchAtLogin,
                    color: CorgiNotch.Colors.style
                ) {
                    LaunchAtLogin.Toggle {
                        Text("")
                    }
                    .labelsHidden()
                }

                SettingsRow(
                    title: "Status Icon",
                    subtitle: "Show icon in menu bar for easy access",
                    icon: CorgiNotch.Assets.icStatusIcon,
                    color: CorgiNotch.Colors.general
                ) {
                    Toggle("", isOn: $appDefaults.showMenuIcon)
                }


            } header: {
                Text("App")
            }

            Section {
                SettingsRow(
                    title: "Disable System HUD",
                    subtitle: "Hide system volume and brightness overlays",
                    icon: CorgiNotch.Assets.icDisableSystemHud,
                    color: CorgiNotch.Colors.systemHud
                ) {
                    Toggle("", isOn: $appDefaults.disableSystemHUD)
                        .onChange(of: appDefaults.disableSystemHUD) { _, newValue in
                            if newValue {
                                requestAccessibilityAndStart()
                            } else {
                                MediaKeyManager.shared.stop()
                            }
                        }
                }

                if appDefaults.disableSystemHUD && !isAccessibilityTrusted {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Accessibility permissions are required.")
                        } icon: {
                            CorgiNotch.Assets.icWarning
                        }
                            .font(.caption)
                            .foregroundStyle(.red)

                        HStack(spacing: 12) {
                            Button("Open System Settings") {
                                NSWorkspace.shared.open(
                                    URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
                                )
                            }
                            .font(.caption)

                            Button("Check Again") {
                                refreshAccessibilityStatus()
                            }
                            .font(.caption)
                        }

                        Text("Tip: If you just rebuilt in Xcode, toggle CorgiNotch off and on again in System Settings > Privacy & Security > Accessibility.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 44)
                }
            } header: {
                Text("System")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
        .onAppear {
            refreshAccessibilityStatus()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
        ) { _ in
            refreshAccessibilityStatus()
        }
    }

    private func refreshAccessibilityStatus() {
        isAccessibilityTrusted = AXIsProcessTrusted()

        if appDefaults.disableSystemHUD && isAccessibilityTrusted {
            MediaKeyManager.shared.start()
        }
    }

    private func requestAccessibilityAndStart() {
        let trusted = AXIsProcessTrusted()
        isAccessibilityTrusted = trusted

        if !trusted {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            AXIsProcessTrustedWithOptions(options as CFDictionary)
        }

        MediaKeyManager.shared.start()
    }
}

#Preview {
    GeneralSettingsView()
}
