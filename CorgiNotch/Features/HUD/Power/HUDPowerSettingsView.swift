//
//  HUDPowerSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 23/03/25.
//

import SwiftUI

struct HUDPowerSettingsView: View {
    
    @StateObject var powerDefaults = HUDPowerDefaults.shared
    
    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Enabled",
                    subtitle: "Shows power state when plugged in/out",
                    icon: CorgiNotch.Assets.icPower,
                    color: CorgiNotch.Colors.power
                ) {
                    Toggle("", isOn: $powerDefaults.isEnabled)
                }
                
                SettingsRow(
                    title: "Show Time Remaining",
                    subtitle: "Displays estimated time remaining on battery",
                    icon: CorgiNotch.Assets.icTimer,
                    color: CorgiNotch.Colors.timer
                ) {
                    Toggle("", isOn: $powerDefaults.showTimeRemaining)
                }
                .disabled(!powerDefaults.isEnabled)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Power")
    }
}

#Preview {
    HUDPowerSettingsView()
}
