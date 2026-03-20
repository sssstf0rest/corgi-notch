//
//  GeneraSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 27/02/25.
//

import SwiftUI
import LaunchAtLogin

struct GeneraSettingsView: View {
    
    @StateObject var appDefaults = AppDefaults.shared
    @StateObject var notchDefaults = NotchDefaults.shared
    
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
                                if !AXIsProcessTrusted() {
                                    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                                    AXIsProcessTrustedWithOptions(options as CFDictionary)
                                }
                                MediaKeyManager.shared.start()
                            } else {
                                MediaKeyManager.shared.stop()
                            }
                        }
                }
                
                if appDefaults.disableSystemHUD && !AXIsProcessTrusted() {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Accessibility permissions are required.")
                        } icon: {
                            CorgiNotch.Assets.icWarning
                        }
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Button("Open System Settings") {
                            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                            AXIsProcessTrustedWithOptions(options as CFDictionary)
                        }
                        .font(.caption)
                    }
                    .padding(.leading, 44) // Indent to align with text
                }
            } header: {
                Text("System")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }
}

#Preview {
    GeneraSettingsView()
}
