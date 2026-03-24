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
- GitHub's `macos-15` runner still uses the system Bash 3.2 shell, so workflow steps cannot rely on Bash 4 features like `mapfile`; the release-archive step must use portable text-file counting instead.
- The first live release run showed `generate_appcast` can hang in GitHub Actions when the workflow imports the Sparkle private key and relies on implicit Keychain lookup.
- For CI, the more reliable approach is to decode the private key file and pass it directly to `generate_appcast --ed-key-file`, avoiding Keychain interaction during appcast generation.
- The startup "Unable to Check For Updates" dialog was caused by eager Sparkle startup from `UpdaterViewModel` combined with builds that could embed an empty `SUPublicEDKey` when the public key was only provided manually at archive time.
- The durable fix is to commit the public EdDSA key into the Xcode build settings and start Sparkle lazily via `SPUUpdater.startUpdater(_:)`, logging launch-time failures silently and only surfacing an alert if the user explicitly requests an update check.
- The disabled `Check for Updates` action after launch was a SwiftUI state propagation bug: the view model exposed `canCheckForUpdates` as a computed property, so the UI never observed Sparkle's availability change after the updater started on the next run loop.
- The version label path is more reliable when it resolves once from `Bundle.main.object(forInfoDictionaryKey:)` and stores the resulting marketing/build string in the shared updater view model.

## Lock Screen Toggle Findings
- The `Show on Lock Screen` toggle is already persisted in `NotchDefaults` and the settings page correctly forces a full notch-window refresh when it changes.
- The actual bug lives in `NotchManager` and `CorgiPanel`: notch panels were always created with `canBecomeVisibleWithoutLogin = true`, so they remained eligible to appear on the lock screen even when the toggle was off.
- The previous "off" branch also inserted panels into `NotchSpaceManager`'s dedicated max-level space instead of restoring ordinary desktop behavior, which kept them tied to a special always-on-top space rather than explicitly keeping them off the lock screen.
- A robust fix should do three things together:
  - configure each panel's login-window visibility from `shownOnLockScreen`
  - stop routing the disabled case into the dedicated notch space
  - explicitly hide the windows on the distributed `com.apple.screenIsLocked` notification and refresh them on unlock

## Lock Screen Toggle Verification
- `xcodebuild -project CorgiNotch.xcodeproj -scheme CorgiNotch -configuration Debug -derivedDataPath /tmp/corgi-notch-lockscreen CODE_SIGNING_ALLOWED=NO build` succeeded after the windowing fix.
- I did not run a live lock/unlock cycle from this environment, so the remaining validation is on-device: toggle `Show on Lock Screen` off, lock the Mac, and confirm the notch no longer appears until the screen is unlocked again.

## Lock Screen Toggle Re-enable Regression
- The first lock-screen fix introduced a follow-up regression: `NotchManager.refreshNotches()` started calling `moveToLockScreen(panel)` before `orderFrontRegardless()`.
- That reversed the original order of operations and meant a newly recreated panel could be moved into the lock-screen space before it was fully realized by AppKit.
- The practical effect was asymmetric behavior:
  - turning `Show on Lock Screen` off worked
  - turning it back on could fail, leaving the notch absent on the lock screen
- Restoring the original order fixes the issue: front/order the panel first, then move it into the lock-screen space.

## Updater Availability Regression
- The greyed-out `Check for Updates` state regressed because `UpdaterViewModel` was still calling `startUpdaterIfNeeded(showErrorToUser: false)` from its initializer.
- That meant Sparkle could begin its own startup/update cycle as soon as the shared updater model was created, which in turn could drive `canCheckForUpdates` to `false` before the user ever clicked the button.
- The intended behavior for this app is simpler: keep the action enabled until the user explicitly asks to check for updates, then start Sparkle on demand.
- Sparkle already documents `SPUUpdater.canCheckForUpdates` as KVO-compliant, so the clean fix is:
  - remove eager startup from `UpdaterViewModel.init()`
  - observe `canCheckForUpdates` directly
  - only mirror Sparkle's disabled state after the updater has actually been started by a user-initiated action

## Packaged App Launch Failure
- The release archive script itself is not the launch blocker; the packaged `.app` was failing during process startup.
- Reproducing the launch path from an extracted `CorgiNotch-2.2.1.zip` showed `dyld` aborting before the app could present UI:
  - `Library not loaded: @rpath/MediaRemoteAdapter.framework/...`
  - `code signature ... not valid for use in process: mapping process and mapped file (non-platform) have different Team IDs`
- The app bundle was signed ad hoc with hardened runtime enabled, and the embedded `MediaRemoteAdapter.framework` was also ad hoc. Without the library-validation exception, macOS rejected the framework load in the packaged app.
- Separately, the generated `Info.plist` still contained `LSBackgroundOnly = true`, which is the wrong app mode for a visible menu-bar / settings app and makes Finder launches behave like a background process instead of a normal agent app.

## Packaged App Launch Fix
- `CorgiNotch.entitlements` now includes `com.apple.security.cs.disable-library-validation = true`, which allows the packaged app to load the embedded `MediaRemoteAdapter.framework` in local/ad hoc builds created by the release script.
- The Xcode target no longer emits `LSBackgroundOnly`; it now emits `LSUIElement = YES` for Debug and Release so the packaged app behaves like a menu-bar agent app.
- I validated the root cause directly against the extracted release zip:
  - before re-signing, the app failed immediately with the `dyld` / `MediaRemoteAdapter.framework` load error
  - after re-signing the extracted app with the new entitlement, the `dyld` failure disappeared and the process stayed alive
- I could not run a fresh archive build in this sandbox because network-restricted package resolution blocked `xcodebuild`, so final end-to-end verification still needs a local archive on your machine.

## Release DMG Packaging
- The repo previously only had a Sparkle-oriented zip builder, which is correct for in-app updates but not ideal for the human-facing GitHub release page.
- A separate DMG helper is the right shape here because Sparkle still requires a `.zip`, while users often expect a drag-install disk image with the app plus an `Applications` shortcut.
- The new `build-release-dmg.sh` mirrors the existing archive build inputs, performs the same archive + `codesign --verify` step, stages:
  - `CorgiNotch.app`
  - `Applications` symlink
- It then creates a compressed `.dmg` with `hdiutil`.

## Repository Rename Follow-up
- Renaming the GitHub repository affects more than README links because the Sparkle feed URL is tied to the GitHub Pages project path.
- In this repo, the rename-sensitive locations are:
  - `SPARKLE_APPCAST_URL` in Xcode build settings
  - release helper script defaults
  - the Sparkle publishing workflow environment
  - README badges, release links, and clone instructions
  - Sparkle setup documentation
- These references need to use the new repository path consistently; otherwise release builds can embed the wrong feed URL and Sparkle update checks will point at the old Pages site.
