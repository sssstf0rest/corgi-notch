//
//  MirrorSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 04/01/2026.
//

import SwiftUI

struct ExpandedMirrorSettingsView: View {
    
    @StateObject private var mirrorDefaults = MirrorDefaults.shared
    @StateObject private var notchDefaults = NotchDefaults.shared
    
    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Corner Radius",
                    subtitle: "Adjust the shape of the mirror",
                    icon: CorgiNotch.Assets.icCornerRadius,
                    color: CorgiNotch.Colors.mirror
                ) {
                    Slider(
                        value: $mirrorDefaults.cornerRadius,
                        in: 15...50,
                        step: 1
                    )
                }
            } header: {
                Text("Mirror Appearance")
            }
            
            Section {
                SettingsRow(
                    title: "Auto-Start Mirror",
                    subtitle: "Automatically activate camera when Expanded Notch opens",
                    icon: CorgiNotch.Assets.icVideo,
                    color: CorgiNotch.Colors.video
                ) {
                    Toggle("", isOn: $mirrorDefaults.autoStart)
                }
            } header: {
                Text("Behavior")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    ExpandedMirrorSettingsView()
}
