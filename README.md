<img src="CorgiNotch/Shared/Assets/CorgiAssets.xcassets/AppIcon.appiconset/CorgiNotch-1024.png" width="200" alt="CorgiNotch app icon" align="left"/>

<div>
<h3 style="font-size: 2.5rem; letter-spacing: 1px;">CorgiNotch</h3>
<p style="font-size: 1.15rem; font-weight: 500;">
    <strong>A maintained continuation of MewNotch for modern macOS.</strong><br>
    CorgiNotch is a free, open-source macOS app that turns the MacBook notch into a configurable, native HUD for brightness, volume, and now-playing controls. Minimal, polished, and privacy-friendly.
  </p>

<br/><br/>

<div align="center">

[![GitHub License](https://img.shields.io/github/license/sssstf0rest/corgi-notch)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/sssstf0rest/corgi-notch/total.svg)](https://github.com/sssstf0rest/corgi-notch/releases)
[![Issues](https://img.shields.io/github/issues/sssstf0rest/corgi-notch.svg)](https://github.com/sssstf0rest/corgi-notch/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/sssstf0rest/corgi-notch.svg)](https://github.com/sssstf0rest/corgi-notch/pulls)
[![macOS Version](https://img.shields.io/badge/macOS-14.0%2B-blue.svg)](https://www.apple.com/macos/)

<br/>

[![Download Latest Release](https://img.shields.io/badge/Download-Latest%20Release-black?style=for-the-badge&logo=apple)](https://github.com/sssstf0rest/corgi-notch/releases)

<br/>

> Preview screenshot coming soon. The fork is currently focused on stability, bug fixing, and macOS compatibility before refreshed preview assets are published.

</div>
</div>

<hr>

> [!NOTE]
> **CorgiNotch** is the Thaw-maintained continuation fork of [MewNotch](https://github.com/monuk7735/mew-notch) by [monuk7735](https://github.com/monuk7735).
> The original project appears to be inactive, so Thaw continues the vision of MewNotch by keeping the project alive, fixing bugs, ensuring compatibility with the latest macOS releases, and eventually implementing the remaining roadmap features.

## Features

- **Brightness HUD** - Displays brightness changes directly in the notch with configurable step sizes.
- **Audio HUD** - Shows output and input volume changes with configurable step sizes and device-aware updates.
- **System HUD Suppression** - Optionally replaces the stock macOS brightness and volume overlays for a cleaner experience.
- **Now Playing Controls** - Expand the notch to see artwork, playback state, track details, progress, and transport controls.
- **Source App Shortcut** - Open the currently playing media app from the expanded now-playing view.
- **Lock Screen Support** - Optionally display the notch overlay on the macOS lock screen.
- **Multi-Display Support** - Show the notch on all displays, notched displays only, or a custom display selection.
- **Full-Screen Awareness** - Automatically hides the notch when full-screen apps are active.
- **Glass Effect and Hover Expansion** - Add visual polish and interactive expansion behavior to the notch.
- **Modern Settings UI** - Configure general behavior, notch behavior, collapsed HUD items, and expanded items from one settings window.
- **Launch at Login and Menu Bar Controls** - Start automatically, open settings quickly, fix the notch, check for updates, or quit from the menu bar.
- **Native macOS Stack** - Built with Swift, SwiftUI, AppKit, and low-level system integrations where needed.

## Installation

### Manual Download

1. Download the latest release from [GitHub Releases](https://github.com/sssstf0rest/corgi-notch/releases).
2. Move `CorgiNotch.app` to the `/Applications` folder.
3. Launch the app and grant the required permissions if prompted.

### Build from Source

1. Clone this repository:

```bash
git clone https://github.com/sssstf0rest/corgi-notch.git
cd corgi-notch
```

2. Open `CorgiNotch.xcodeproj` in a recent version of Xcode.
3. Build and run the `CorgiNotch` scheme.
4. If you want system HUD suppression, grant Accessibility permission when prompted.

### "Damaged" or "Unidentified Developer" Warning

If you are running an unsigned release or a locally built copy, macOS Gatekeeper may block the app on first launch.

**Option 1 (Recommended): Allow via System Settings**

1. Open **System Settings** → **Privacy & Security**.
2. Scroll to the **Security** section.
3. Look for the message saying **CorgiNotch** was blocked and click **Open Anyway**.
4. Confirm the launch in the follow-up dialog.

**Option 2 (Advanced): Remove the quarantine attribute**

```bash
xattr -cr /Applications/CorgiNotch.app
```

This removes the quarantine flag that macOS adds to downloaded apps.

## Usage

1. Launch **CorgiNotch**.
2. Open **Settings** from the menu bar or the notch gear button.
3. Adjust brightness or volume to see the collapsed HUD in action.
4. Start media playback to use the expanded now-playing view and playback controls.
5. Customize display targeting, hover behavior, glass effect, and expanded items to fit your setup.
6. If you enable system HUD suppression, make sure Accessibility permission is granted.

## Roadmap

- [x] Brightness and audio HUD support
- [x] Expandable now-playing experience
- [x] Multi-display targeting and notch visibility controls
- [x] Launch at login, menu bar controls, and in-app update support
- [x] Modernized settings structure for notch, collapsed items, and expanded items
- [ ] Continue bug-fix and stability work across the current feature set
- [ ] Keep the app compatible with upcoming macOS releases
- [ ] Improve release and distribution polish for the fork
- [ ] Revisit and complete the remaining long-term MewNotch roadmap items once the maintenance baseline is stable

## Dependencies

- [Lottie](https://github.com/airbnb/lottie-ios)
- [LaunchAtLogin-Modern](https://github.com/sindresorhus/LaunchAtLogin-Modern)
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [Sparkle](https://github.com/sparkle-project/Sparkle)
- [MacroVisionKit](https://github.com/TheBoredTeam/MacroVisionKit)

## Contributing

Contributions are welcome.

If you want to help:

- open an issue for bugs, regressions, or macOS compatibility problems
- submit pull requests for focused fixes or improvements
- include clear reproduction steps, macOS version, hardware details, and permission state for system-integration issues

Before opening a larger change, it helps to start a discussion in an issue so the direction stays aligned with the fork's maintenance goals.

## License

This project is licensed under the [GPLv3 License](LICENSE).

## Acknowledgments

- Forked from [MewNotch](https://github.com/monuk7735/mew-notch) by [monuk7735](https://github.com/monuk7735).
- Thaw continues the project with a focus on maintenance, bug fixes, and modern macOS compatibility.
- Built with Swift, SwiftUI, AppKit, and Objective-C system bridges.

Thanks to the projects and authors whose code or ideas helped shape this work:

- [mediaremote-adapter](https://github.com/ungive/mediaremote-adapter)
- [SlimHUD](https://github.com/AlexPerathoner/SlimHUD)
- [SkyLightWindow](https://github.com/Lakr233/SkyLightWindow)
- [EnergyBar](https://github.com/billziss-gh/EnergyBar)
- [boring.notch](https://github.com/TheBoredTeam/boring.notch)
