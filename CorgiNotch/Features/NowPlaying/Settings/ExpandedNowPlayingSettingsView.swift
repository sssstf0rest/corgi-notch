//
//  NowPlayingSettingsView.swift
//  CorgiNotch
//
//  Created by Monu Kumar on 04/01/2026.
//

import SwiftUI

struct ExpandedNowPlayingSettingsView: View {
    
    @StateObject private var nowPlayingDefaults = NowPlayingDefaults.shared
    @StateObject private var notchDefaults = NotchDefaults.shared
    
    var body: some View {
        Form {
            Section {
                SettingsRow(
                    title: "Corner Radius",
                    icon: CorgiNotch.Assets.icCornerRadius,
                    color: CorgiNotch.Colors.albumArt
                ) {
                    Slider(value: $nowPlayingDefaults.albumArtCornerRadius, in: 15...50, step: 1)
                }
                
                SettingsRow(
                    title: "Show Artist",
                    icon: CorgiNotch.Assets.icArtist,
                    color: CorgiNotch.Colors.artist
                ) {
                    Toggle("", isOn: $nowPlayingDefaults.showArtist)
                }
                
                SettingsRow(
                    title: "Show Album",
                    icon: CorgiNotch.Assets.icAlbumName,
                    color: CorgiNotch.Colors.albumName
                ) {
                    Toggle("", isOn: $nowPlayingDefaults.showAlbum)
                }
                
                SettingsRow(
                    title: "Show App Icon",
                    icon: CorgiNotch.Assets.icAppIcon,
                    color: CorgiNotch.Colors.appIcon
                ) {
                    Toggle("", isOn: $nowPlayingDefaults.showAppIcon)
                }
            } header: {
                Text("General Settings")
            }
        }
        .formStyle(.grouped)
    }
}

#Preview {
    ExpandedNowPlayingSettingsView()
}
