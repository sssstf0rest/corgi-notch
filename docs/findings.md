# Findings & Decisions

## Requirements
- Rebuild the project structure to make it simpler and more atomic.
- Keep all current features, including music-related behavior, file drop/shelf behavior, AirDrop, brightness control, volume control, and related current functionality.
- Do not add new features during the rebuild.
- Make the settings page the full control surface for existing app behavior.
- Stay in planning mode for now; do not implement the rebuild yet.
- Keep planning artifacts in markdown files under `docs/`.

## Research Findings
- The project baseline has already been promoted from `OldProject` into `CorgiNotch/` with `CorgiNotch.xcodeproj/`.
- The current app builds successfully and should be treated as the functional baseline to preserve during the rebuild.
- The current codebase is broad and mixes UI, defaults storage, view models, helpers, managers, and feature behavior across folders such as `View`, `ViewModel`, `DB`, and `Utils`.
- The existing runtime depends on SwiftUI, Objective-C bridging helpers, private frameworks, Sparkle, Lottie, SwiftyJSON, LaunchAtLogin, and MacroVisionKit.
- The rebuild plan must separate "cleaner structure" from "behavior changes"; preserving feature parity is a hard constraint.
- The top-level app structure is still primarily technical-layer based: `DB`, `Models`, `Resources`, `Utils`, `View`, and `ViewModel`.
- Current feature behavior is split across many locations: notch window orchestration in `Utils/NotchManager.swift`, settings control pages under `View/Settings`, feature defaults under `DB/UserDefaults`, and feature view models under `ViewModel`.
- Music/now-playing functionality spans `Models/NowPlayingMediaModel.swift`, `Utils/Helpers/Media/NowPlaying.swift`, notch view models, and multiple notch/settings views.
- File drop and file shelf behavior is handled inside notch UI views such as `View/Notch/NotchView.swift` and `View/Notch/Expanded/ParentViews/FileShelfView.swift`, not through a dedicated drop/file-shelf feature module.
- AirDrop is currently wrapped in `Utils/Managers/AirDropManager.swift`; brightness and volume control depend on mixed helper/manager/default/view model layers rather than a single feature boundary.
- `boring.notch` positions its notch app around clear user-facing feature groups: music controls, calendar/reminders, file shelf with AirDrop, and HUD replacement, while also showing separate infrastructure areas such as an XPC helper, configuration, updater, and app target.
- `NotchDrop` is narrowly focused on notch-as-drop-zone behavior, with a small top-level structure centered around the app target, project, and shared resources; its README emphasizes drag/drop and AirDrop as the main product surface.
- `NotchPrompter` is much narrower in scope, but it reinforces the value of a small app target with obvious supporting folders (`docs`, tests, website) and a concise feature story instead of a deeply interleaved internal structure.
- `DynamicNotchKit` is a reusable package rather than a full app, but it is important as a structural reference: notch-area mechanics are packaged as dedicated infrastructure instead of being intertwined with feature-specific UI and state.
- The external references suggest a useful split for the rebuild: isolate notch/window/runtime infrastructure, then build feature modules on top of it with their own views, state, settings, and services.
- Apple documents `MenuBarExtra` as the persistent menu-bar scene for utility apps, which matches the current app shell and argues for keeping menu-bar concerns in a small app-shell layer rather than inside feature code.
- Apple documents `NSPanel` as an auxiliary window type under the AppKit windows/panels model, which fits the notch-window role and suggests keeping custom notch-window behavior in a dedicated infrastructure layer.
- Apple documents `NSWindow.CollectionBehavior.canJoinAllSpaces` as the behavior that allows a window to appear in all spaces; this is directly relevant to lock-screen/full-screen/notch-space handling and supports isolating space/window policy from feature UI.
- Apple documents `NSItemProvider` as the cross-process drag/drop payload type and notes asynchronous loading behavior, which is directly relevant to file-shelf and drop-zone planning.
- Apple documents `NSSharingServicePicker` as the standard macOS share sheet/picker and `NSSharingService` as the underlying sharing service abstraction, which is directly relevant to AirDrop handling and argues against burying sharing logic deep inside unrelated view code.
- `CorgiSettingsView.swift` is a compact navigation shell, but the settings system beneath it is still organized more by page tree than by feature ownership.
- `NotchView.swift` combines notch composition, hover/tap behavior, drop handling, and expanded-view switching, which makes it a likely rebuild split point.
- `NotchManager.swift` currently owns panel creation, screen enumeration, full-screen visibility updates, and space-placement policy in one manager.
- `NotchDefaults.swift` centralizes many notch settings behind one singleton object, which is convenient for wiring but weak for atomic feature ownership.
- Core coordination files are each moderate in size, but together they create cross-layer coupling between views, view models, defaults, and runtime managers.
- `NotchViewModel.swift` mixes notch geometry, animation state, hover/tap behavior, timing, and haptics in one view model, which makes it another likely split point between presentation state and interaction policy.
- `CorgiDefaultsManager.swift` is effectively an empty placeholder today, so it does not provide meaningful organization despite being used in the settings shell.
- `ExpandedItemsSettingsView.swift` mutates `NotchDefaults` directly for enablement and ordering, which reinforces that settings logic is currently embedded in views instead of in feature-scoped settings models or coordinators.
- The planning workspace is now fully consolidated under `docs/` with `task_plan.md`, `findings.md`, `progress.md`, `rebuild-architecture.md`, and `rebuild-plan.md`.

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| Use the current `CorgiNotch` app as the source of truth for feature parity | It is the maintained fork baseline and already builds |
| Research external notch projects before proposing architecture | The user explicitly wants the plan informed by existing notch implementations |
| Research relevant macOS APIs alongside project references | The rebuild should reflect real platform constraints, not just folder reshuffling |
| Treat the existing technical-layer foldering as a likely rebuild target, not a model to preserve | The user's stated goal is a clearer, simpler, more atomic structure |
| Use `DynamicNotchKit` primarily as an infrastructure reference and the notch apps primarily as feature-organization references | They answer different planning questions: window/notch mechanics versus product-level feature grouping |
| Plan around three clear layers: app shell, notch/runtime infrastructure, and feature modules | This fits both the Apple API model and the external project patterns better than the current mixed layering |
| Keep the settings UI unified, but back it with feature-scoped settings/state objects | The user wants one control surface without preserving the current structural sprawl behind it |
| Remove or repurpose placeholder organizational types during the rebuild instead of preserving them for nominal structure | Empty abstractions like `CorgiDefaultsManager` add indirection without helping the architecture |
| Capture the proposed architecture and ordered rebuild checklist as separate docs | This keeps research, architecture, and execution planning distinct and easier to maintain |

## Issues Encountered
| Issue | Resolution |
|-------|------------|

## Resources
- Project root: `/Users/sssst/Files/Workspace/Repos/corgi-notch`
- Current app tree: `/Users/sssst/Files/Workspace/Repos/corgi-notch/CorgiNotch`
- Current Xcode project: `/Users/sssst/Files/Workspace/Repos/corgi-notch/CorgiNotch.xcodeproj/project.pbxproj`
- Legacy reference source: `/Users/sssst/Files/Workspace/Repos/corgi-notch/OldProject`
- Reference repo: https://github.com/TheBoredTeam/boring.notch
- Reference repo: https://github.com/Lakr233/NotchDrop
- Reference repo: https://github.com/jpomykala/NotchPrompter
- Reference repo: https://github.com/MrKai77/DynamicNotchKit
- Apple docs: https://developer.apple.com/documentation/swiftui/menubarextra
- Apple docs: https://developer.apple.com/documentation/appkit/windows-panels-and-screens
- Apple docs: https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct/canjoinallspaces
- Apple docs: https://developer.apple.com/documentation/foundation/nsitemprovider
- Apple docs: https://developer.apple.com/documentation/appkit/nssharingservicepicker
- Architecture proposal: `/Users/sssst/Files/Workspace/Repos/corgi-notch/docs/rebuild-architecture.md`
- Rebuild checklist: `/Users/sssst/Files/Workspace/Repos/corgi-notch/docs/rebuild-plan.md`

## Visual/Browser Findings
- `boring.notch` exposes a broad app structure with separate helper/configuration/updater areas and publicly frames the product around music, shelf/AirDrop, and HUD-replacement features.
- `NotchDrop` frames the notch as a focused drop zone and highlights drag/drop plus AirDrop as a self-contained feature set.
- `NotchPrompter` shows a simpler app with clear supporting folders and a very constrained feature story.
- `DynamicNotchKit` presents notch integration as reusable infrastructure for custom windows, insets, and safe-area handling rather than as a full end-user feature bundle.
- Apple’s docs frame `MenuBarExtra` as the app-shell scene, `NSPanel` as an auxiliary window model, `canJoinAllSpaces` as explicit space behavior, `NSItemProvider` as async drag/drop payload transport, and `NSSharingServicePicker` as the standard share-sheet entry point.

---
*Update this file after every 2 view/browser/search operations*
