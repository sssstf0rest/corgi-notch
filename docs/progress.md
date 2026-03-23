# CorgiNotch

A macOS menu bar app that replaces the MacBook notch area with an interactive, customizable overlay. It displays system HUDs (volume, brightness, media) inside the notch and expands to show now-playing media controls.

## Features

### App

- **Launch at Login** - Auto-start on login via LaunchAtLogin
- **Menu Bar Icon** - Togglable status icon for quick access to settings, fix notch, check for updates, and quit
- **Dock Behavior** - Runs as a menu bar accessory; dock icon appears only while the settings window is open
- **Auto Updates** - Check for updates via Sparkle framework

### Notch Display

- **Multi-Display Support** - Show notch overlay on all displays, notched displays only, or a custom selection
- **Lock Screen** - Optionally display the notch on the login/lock screen
- **Full-Screen Hiding** - Automatically hide when a full-screen app is active
- **Height Mode** - Match physical notch, match menu bar, or set a manual height
- **Glass Effect** - Glass morphism styling (macOS 26.0+); forces expand-on-hover when enabled
- **Haptic Feedback** - Vibration on hover and expansion

### Notch Interaction

- **Expand on Hover** - Hover for ~400ms to expand the notch
- **Click to Expand** - Single click expands with a spring animation
- **Context Menu** - Right-click for Fix Notch, Settings (Cmd+,), Quit (Cmd+R), and Check for Updates

### Collapsed Notch (HUD)

Transient overlays that appear inside the collapsed notch when a system property changes, then auto-hide after ~1 second.

- **Audio Output Volume** - Shows volume percentage and output device name on change
- **Audio Input Volume** - Shows microphone level and input device name on change
- **Brightness** - Shows brightness percentage on change
- **Media** - Shows currently playing app with animation
- **Screen Lock Status** - Animated lock/unlock indicator
- **Step Size Control** - Configurable increment for volume (1-10%) and brightness (1-10%)
- **Disable System HUD** - Replaces native macOS volume/brightness overlays (requires Accessibility permission)

### Expanded Notch (Now Playing)

Full media controls shown when the notch is expanded.

- **Album Art** - Artwork display with configurable corner radius (slider, 15-50)
- **Track Info** - Title, artist (togglable), album (togglable)
- **Playback Controls** - Previous, play/pause, next (appear on hover over the details area)
- **Progress Bar** - Elapsed time, total duration, and a progress slider
- **App Icon Badge** - Clickable overlay on album art that launches the source music app
- **Expanded Item Management** - Enable/disable and reorder expanded items from settings

### Settings

Five settings pages accessible via the menu bar icon or Cmd+,:

| Page | Contents |
|------|----------|
| **General** | Launch at Login, Status Icon, Disable System HUD (with accessibility permission flow) |
| **Notch** | Display selection, lock screen, full-screen, height mode, glass effect, hover, haptics |
| **Collapsed** | Audio (enable, step size), Brightness (enable, step size), Media (enable) |
| **Expanded** | Item list with enable/reorder, Now Playing settings (corner radius, artist, album, app icon) |
| **About** | App icon, version, Check for Updates button |

### System Integrations

- **MediaRemote** - Now-playing metadata and playback control via private framework
- **Media Key Interception** - Captures volume/brightness keys when system HUD is disabled (MediaKeyManager, requires Accessibility)
- **Audio I/O Monitoring** - Tracks output/input volume and device changes via CoreAudio (Objective-C bridge)
- **Brightness Monitoring** - Tracks display brightness changes (Objective-C bridge)
- **Screen Lock Detection** - Listens for `com.apple.screenIsLocked` / `com.apple.screenIsUnlocked` distributed notifications
- **Full-Screen Detection** - Monitors active space changes to detect full-screen apps
- **NSPanel Windowing** - Non-activating floating panel with custom notch shape mask, positioned per-display

### Architecture

4-layer structure:

```
CorgiNotch/
  App/              - Entry point, app delegate, settings shell
  Infrastructure/   - Windowing, space management, system adapters, persistence
  Features/         - NotchPresentation, NowPlaying, HUD, AppSettings
  Shared/           - Assets, extensions, models, UI components
```

## Changelog

### 2026-03-22
- Removed "Show in Dock" feature (dock icon now only appears while settings window is open)
- Fixed settings window close not hiding dock icon
- Restored `docs/task_plan.md` and `docs/findings.md` for the settings-window foreground fix session
- Audited the live repository structure, dependencies, and app/window lifecycle before implementing the next settings-window activation fix
- Introduced a shared settings-window presenter so all settings entry points can force the settings window to the foreground
- Replaced the deprecated foreground activation path with `NSApp.activate(ignoringOtherApps: true)` plus explicit settings-window ordering and revalidated with a successful `xcodebuild`
- Fixed custom Audio/Brightness decrement floors so non-default step sizes no longer leave a faint non-zero system value when the HUD reaches `0%`
- Output audio now hard-mutes at the custom-step zero floor, and brightness snaps sub-visible residual values to a real zero
- Rewrote `README.md` to accurately present CorgiNotch as the Thaw-maintained continuation fork of MewNotch and removed unrelated placeholder project text
- Audited the current Sparkle setup and confirmed the updater is wired in code but blocked by a placeholder feed URL and missing public key
- Added build-setting-backed Sparkle configuration so release builds embed the appcast URL and public EdDSA key instead of placeholder values
- Added `scripts/release/build-release-archive.sh` and `scripts/release/fetch-sparkle-tools.sh` for maintainer-side Sparkle release preparation
- Added `.github/workflows/publish-sparkle-appcast.yml` to publish GitHub Release archives into a `gh-pages` Sparkle update site and regenerate `appcast.xml`
- Added `docs/sparkle-release-flow.md` documenting one-time key setup, GitHub Pages configuration, and the release publishing flow
- Corrected the workflow so it stages the new archive outside `gh-pages` before copying it in, which avoids false multi-archive failures after the first published update
- Verified with a local Debug build that the processed app bundle contains the configured `SUFeedURL` and `SUPublicEDKey`
- Fixed the release workflow on GitHub Actions by removing the Bash-4-only `mapfile` call from the archive download step; the `macos-15` runner uses Bash 3.2, so the workflow now uses a portable archive list file instead

### 2026-03-21
- Removed album-art click navigation and Chrome tab matching (source app launches via app icon badge only)
- Simplified collapsed HUD styles: removed style pickers for Audio and Brightness, forced Minimal style
- Unified audio input/output HUD toggle into a single Audio enabled switch
- Removed auto-brightness toggle from Brightness HUD settings
- Made step size controls always visible regardless of HUD enabled state
- Changed glass effect and expand-on-hover to default to enabled
- Removed show dividers default (off by default)

### 2026-03-20
- Restructured project into 4-layer architecture (App / Infrastructure / Features / Shared)
- Removed features: File Shelf, AirDrop, Power HUD, Mirror, Bash, animated HUD values
- Fixed drag-and-drop panel interaction (NSPanel style mask)
- Added accessibility permission check with guided setup in settings
- Added dock icon lifecycle (appears when settings opens, hides on close)
