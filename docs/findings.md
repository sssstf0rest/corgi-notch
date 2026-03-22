# Findings: Settings Window Foreground Fix

## Repository State
- The current repository keeps only one markdown file in `docs/`: `progress.md`.
- The live source tree is the authoritative current state; earlier planning/history files are no longer present in `docs/`.
- The worktree is dirty with many pre-existing changes unrelated to this task, so the fix should avoid reverting unrelated files.

## Project Purpose
- `CorgiNotch` is a macOS menu bar app that replaces the MacBook notch area with a per-display overlay window.
- The overlay has a collapsed HUD mode for system changes like volume/brightness/media and an expanded mode focused on now-playing media controls.
- Settings are exposed through a SwiftUI settings window and can also be opened from the notch UI and menu bar.

## Tech Stack
- Primary language/UI stack: Swift + SwiftUI.
- App shell and window/system integration: AppKit (`NSApplicationDelegate`, `NSWindow`, `NSPanel`, `NSWorkspace`, `NSRunningApplication`).
- Persistence: custom `PrimitiveUserDefault` and `CodableUserDefault` wrappers plus `@AppStorage`.
- Objective-C bridge: bridging header plus native adapters for audio/brightness/media-related system APIs.
- Private/system frameworks in use include `MediaRemote`, `DisplayServices`, and `SkyLight`.

## Dependency Structure
- Swift Package Manager dependencies pinned in `CorgiNotch.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`:
  - `Sparkle` for updates
  - `LaunchAtLogin-Modern` for login-item support
  - `MacroVisionKit` for full-screen/space monitoring
  - `Lottie` for animations
  - `SwiftyJSON`
- Internal dependency shape:
  - `App/` owns app launch, settings shell, updater, and lifecycle coordination.
  - `Infrastructure/` owns persistence, windowing, space management, and system adapters.
  - `Features/` owns notch presentation, HUDs, settings subpages, and now-playing UX.
  - `Shared/` owns reusable assets, extensions, models, and UI primitives.

## Current Architecture
- The app currently follows a 4-layer structure:
  - `App`
  - `Infrastructure`
  - `Features`
  - `Shared`
- `CorgiNotchApp` defines a `MenuBarExtra` and a SwiftUI `Settings` scene.
- `CorgiAppDelegate` initializes system listeners, starts media/brightness/audio services, refreshes notch windows, and sets the app activation policy to `.accessory`.
- `NotchManager` creates one custom non-activating panel per eligible screen and hosts `NotchView` inside it.
- `NotchView` composes collapsed and expanded notch content and wires hover/tap behavior to `NotchViewModel`.

## Build and Run Flow
- Build system: Xcode app project (`CorgiNotch.xcodeproj`) with SwiftPM dependencies.
- Run flow:
  - `CorgiNotchApp` launches.
  - `CorgiAppDelegate.applicationDidFinishLaunching` starts listeners and calls `NotchManager.shared.refreshNotches`.
  - `NotchManager` creates `CorgiPanel` windows per display and hosts `NotchView`.
  - The app runs as a menu bar accessory until settings are shown, at which point the activation policy is switched to `.regular`.
- Typical verification command:
  - `xcodebuild -project CorgiNotch.xcodeproj -scheme CorgiNotch -configuration Debug -derivedDataPath /tmp/corgi-notch-derived CODE_SIGNING_ALLOWED=NO build`

## Settings Window Bug Cause
- The expanded-notch gear button in `SettingsControlView` currently calls SwiftUI’s `openSettings` action directly.
- The settings window is partially foregrounded today via a `.task` in `CorgiSettingsView`, which changes activation policy and calls `NSApp.activate()`.
- That approach is not reliable when the settings window already exists, because reopening an existing settings window does not depend on that view task running again.
- The more reliable fix is to centralize settings-window presentation so it:
  - switches activation policy to `.regular`
  - opens the settings scene
  - explicitly activates the app
  - makes the settings window key and orders it front

## Implemented Direction
- Added a shared `SettingsWindowPresenter` in `App/Settings` so settings opening and settings foregrounding now use one path.
- The presenter is wired into the expanded-notch gear button, the notch/menu Settings action, and the app reopen flow.
- `CorgiSettingsView` still configures the window chrome and delegate, but it now reuses the same foreground presenter instead of having a second independent activation path.
- The presenter uses `NSApp.setActivationPolicy(.regular)`, `openSettings()`, `NSApp.activate(ignoringOtherApps: true)`, `makeKeyAndOrderFront`, and `orderFrontRegardless`, with immediate and deferred foreground passes so an already-existing SwiftUI settings window is still raised reliably.

## Verification
- `xcodebuild -project CorgiNotch.xcodeproj -scheme CorgiNotch -configuration Debug -derivedDataPath /tmp/corgi-notch-derived CODE_SIGNING_ALLOWED=NO build` succeeded after the presenter change.
- New foreground logic compiled cleanly; the remaining warnings are pre-existing:
  - `#pragma once in main file` from `CorgiNotch-Bridging-Header.h`
  - `MediaRemoteAdapter.framework` was built for a newer macOS version
  - App Intents metadata extraction skipped because the app has no `AppIntents.framework` dependency

## Custom Step Zero-Floor Bug
- The Audio and Brightness HUDs display whole percentages, but the intercepted decrement path in `MediaKeyManager` operated on raw scalar values.
- With non-default custom step sizes, a decrement could leave a tiny positive residual value that still rounded to `0%` in the HUD.
- That made the notch overlay appear to hit zero while the real output volume still had faint sound or the display still had a little backlight.

## Custom Step Zero-Floor Fix
- The floor behavior is now handled in `MediaKeyManager` itself, where the custom step interception happens.
- For both volume and brightness, any downward result that would round to `0%` in the HUD is now snapped to a real system zero before being written back.
- Output volume also explicitly sets mute when that snapped floor is reached, so `0%` means true silence instead of a barely-audible residual level.

## Follow-up Verification
- `xcodebuild -project CorgiNotch.xcodeproj -scheme CorgiNotch -configuration Debug -derivedDataPath /tmp/corgi-notch-derived CODE_SIGNING_ALLOWED=NO build` succeeded after the zero-floor fix.
- I did not run a live hardware validation for brightness/audio keys from this environment, so the remaining validation is an on-device check with a non-default step size such as `3%`.

## Sparkle Release Flow Findings
- The app already instantiates `SPUStandardUpdaterController` in `UpdaterViewModel`, so the UI-side updater hook exists.
- Sparkle is currently non-functional because `SUFeedURL` in `Info.plist` points to `https://example.com/corgi-notch/appcast.xml`, and `SUPublicEDKey` is empty.
- GitHub Releases alone are not sufficient for Sparkle. The project still needs:
  - a real appcast feed URL
  - a Sparkle EdDSA public key embedded in the app
  - a private key kept outside the repo for signing update metadata
  - generated `appcast.xml` entries and signed update archives
- The cleanest hosting model for this repo is:
  - GitHub Releases for human-facing release downloads
  - GitHub Pages on `gh-pages` for Sparkle assets (`appcast.xml`, archives, and delta files)
- To preserve Sparkle delta generation, each release job needs access to prior update archives before re-running `generate_appcast`, which makes a persistent `gh-pages` branch a good fit.
- The current repo has no `.github/workflows` directory yet, so Sparkle publishing automation must be added from scratch.
- The implemented workflow has to download the new release archive into a temporary directory before copying it into `gh-pages`; otherwise older `CorgiNotch*.zip` files already stored in `gh-pages` would break the "exactly one release asset" validation on later releases.
- A local verification build confirmed the processed app bundle now embeds the configured `SUFeedURL` and `SUPublicEDKey`, so the new build-setting wiring for Sparkle is functioning.
