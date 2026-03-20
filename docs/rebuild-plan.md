# Plan

Rebuild `CorgiNotch` around a clearer feature-oriented architecture while preserving all existing behavior. The approach is to separate app shell and notch/runtime infrastructure from feature modules, then move settings ownership into those feature modules so the settings app remains the single control surface without keeping the current cross-layer sprawl.

## Scope
- In: architecture redesign, file/folder reorganization, feature-boundary cleanup, settings ownership cleanup, parity verification planning.
- Out: new features, product-scope expansion, behavior redesign, UX experiments unrelated to preserving current functionality.

## Action items
[x] Freeze the current feature baseline by documenting all preserved features and the files that currently implement them.
[x] Define the target module layout under `CorgiNotch/App`, `CorgiNotch/Infrastructure`, `CorgiNotch/Features`, and `CorgiNotch/Shared`.
[x] Split notch runtime responsibilities by extracting window/space/screen mechanics out of feature views and into dedicated infrastructure modules.
[x] Rebuild feature areas one at a time: `NotchPresentation`, `NowPlaying`, `FileShelf`, `AirDrop`, `HUD` subfeatures, `Mirror`, and `Bash`.
[x] Isolate private-framework and Objective-C bridge integrations behind infrastructure adapters so feature modules do not talk to platform internals directly.
[x] Preserve stored preferences by mapping existing `UserDefaults` keys and identifying any migrations required before code moves.
[x] Verify parity after each migration slice with targeted `xcodebuild` checks and a manual regression matrix for multi-display, full-screen, lock-screen, drag/drop, AirDrop, and media/HUD behavior.
[ ] Refactor settings ownership so each feature exports its own settings state and settings views while the settings shell remains a navigation container.

## Feature Baseline (Frozen)

### Feature: App Shell
| Responsibility | Current File |
|---|---|
| App entry point, menu bar extra, settings scene | `CorgiNotchApp.swift` |
| App lifecycle, system listener init | `CorgiAppDelegate.swift` |
| Assets, colors, icon definitions | `Resources/CorgiNotch.swift` |
| Menu bar context menu (Fix Notch, Settings, Quit, Update) | `View/Common/NotchOptionsView.swift` |
| App-level defaults (menu icon, system HUD toggle) | `DB/UserDefaults/App/AppDefaults.swift` |
| Placeholder defaults manager (empty) | `DB/UserDefaults/CorgiDefaultsManager.swift` |
| App kill/restart | `Utils/Managers/AppManager.swift` |
| Auto-updater via Sparkle | `ViewModel/UpdaterViewModel.swift` |

### Feature: Notch Window System (Infrastructure)
| Responsibility | Current File |
|---|---|
| Panel creation, display management, fullscreen monitor | `Utils/NotchManager.swift` |
| CGSSpace management for all-spaces placement | `Utils/NotchSpaceManager.swift` |
| SkyLight space for lock screen placement | `Utils/Managers/WindowManager.swift` |
| Notch size/position calculation | `Utils/NotchUtils.swift` |
| Custom floating NSPanel | `View/Common/CorgiWindow.swift` |
| Notch shape mask | `View/Common/Shapes/NotchShape.swift` |

### Feature: NotchPresentation (Collapsed/Expanded state)
| Responsibility | Current File |
|---|---|
| Root notch view (collapsed/expanded switch, drag-drop, hover) | `View/Notch/NotchView.swift` |
| Collapsed notch composition, HUD layout | `View/Notch/Collapsed/CollapsedNotchView.swift` |
| Collapsed-only notch (no HUD active) | `View/Notch/Collapsed/OnlyNotchView.swift` |
| Expanded notch composition, tabs, controls | `View/Notch/Expanded/ExpandedNotchView.swift` |
| Expanded home view (item grid) | `View/Notch/Expanded/ParentViews/NotchHomeView.swift` |
| Notch state VM (hover, expand, pin, sizing) | `ViewModel/Notch/NotchViewModel.swift` |
| Collapsed VM (HUD state, media, lock) | `ViewModel/Notch/CollapsedNotchViewModel.swift` |
| Expanded VM (current view, shelf, media) | `ViewModel/Notch/ExpandedNotchViewModel.swift` |
| Notch defaults (display, height, glass, hover, haptics, items) | `DB/UserDefaults/App/NotchDefaults.swift` |
| Notch settings page | `View/Settings/Pages/NotchSettingsView.swift` |
| Notch settings VM (screens, refresh) | `ViewModel/NotchSettingsViewModel.swift` |
| Haptics | `Utils/Managers/HapticsManager.swift` |

### Feature: NowPlaying
| Responsibility | Current File |
|---|---|
| MediaRemote adapter, playback state | `Utils/Helpers/Media/NowPlaying.swift` |
| Now playing data model | `Models/NowPlayingMediaModel.swift` |
| Expanded detail view (art, controls, slider) | `View/Notch/Expanded/ItemViews/NowPlayingDetailView.swift` |
| Collapsed left HUD (album art) | `View/Notch/Collapsed/HUDView/Minimal/NowPlayingHUDLeftView.swift` |
| Collapsed right HUD (track info) | `View/Notch/Collapsed/HUDView/Minimal/NowPlayingHUDRightView.swift` |
| Defaults (corner radius, show artist/album/icon) | `DB/UserDefaults/ExpandedItems/NowPlayingDefaults.swift` |
| Settings page | `View/Settings/Pages/Expanded/Items/ExpandedNowPlayingSettingsView.swift` |

### Feature: FileShelf
| Responsibility | Current File |
|---|---|
| Shelf parent view | `View/Notch/Expanded/ParentViews/FileShelfView.swift` |
| File group view (thumbnails, drag-out) | `View/Notch/Expanded/ItemViews/ShelfFileGroupView.swift` |
| Shelf control button | `View/Notch/Expanded/Controls/FileShelfControlView.swift` |
| File group model | `Models/ShelfFileGroupModel.swift` |
| Shelf defaults (persisted file groups) | `DB/UserDefaults/ExpandedItems/ShelfDefaults.swift` |
| Multi-drag preview modifier | `View/Modifiers/MultiDragPreviewSource.swift` |

### Feature: AirDrop
| Responsibility | Current File |
|---|---|
| NSSharingService wrapper | `Utils/Managers/AirDropManager.swift` |

### Feature: HUD/Audio
| Responsibility | Current File |
|---|---|
| Volume read/mute detection | `Utils/Managers/VolumeManager.swift` |
| Media key interception (volume keys) | `Utils/Managers/MediaKeyManager.swift` |
| Audio input defaults | `DB/UserDefaults/HUD/HUDAudioInputDefaults.swift` |
| Audio output defaults | `DB/UserDefaults/HUD/HUDAudioOutputDefaults.swift` |
| Audio HUD settings page | `View/Settings/Pages/Collapsed/Items/HUDAudioSettingsView.swift` |
| Audio settings VM (debounced step) | `ViewModel/HUDAudioSettingsViewModel.swift` |
| Audio device HUD view | `View/Notch/Collapsed/HUDView/AudioDeviceHUDView.swift` |

### Feature: HUD/Brightness
| Responsibility | Current File |
|---|---|
| Media key interception (brightness keys) | `Utils/Managers/MediaKeyManager.swift` |
| Brightness defaults | `DB/UserDefaults/HUD/HUDBrightnessDefaults.swift` |
| Brightness HUD settings page | `View/Settings/Pages/Collapsed/Items/HUDBrightnessSettingsView.swift` |
| Brightness settings VM | `ViewModel/HUDBrightnessSettingsViewModel.swift` |

### Feature: HUD/Power
| Responsibility | Current File |
|---|---|
| Battery/charging state | `Utils/Managers/PowerManager.swift` |
| Power defaults | `DB/UserDefaults/HUD/HUDPowerDefaults.swift` |
| Power HUD view | `View/Notch/Collapsed/HUDView/PowerHUDView.swift` |
| Power settings page | `View/Settings/Pages/Collapsed/Items/HUDPowerSettingsView.swift` |

### Feature: HUD/Media
| Responsibility | Current File |
|---|---|
| Media HUD defaults | `DB/UserDefaults/HUD/HUDMediaDefaults.swift` |
| Media HUD settings page | `View/Settings/Pages/Collapsed/Items/HUDMediaSettingsView.swift` |

### Feature: HUD Shared
| Responsibility | Current File |
|---|---|
| HUD defaults protocol | `DB/UserDefaults/HUD/HUDDefaultsProtocol.swift` |
| HUD property model (icon, value, timer) | `Models/HUDPropertyModel.swift` |
| HUD enums (style) | `Models/Enums/HUDEnums.swift` |
| Minimal HUD view | `View/Notch/Collapsed/HUDView/Minimal/MinimalHUDView.swift` |
| Minimal left/right views | `View/Notch/Collapsed/HUDView/Minimal/MinimalHUDLeftView.swift`, `MinimalHUDRightView.swift` |
| Progress HUD view | `View/Notch/Collapsed/HUDView/ProgressHUDView.swift` |
| Notched HUD view | `View/Notch/Collapsed/HUDView/NotchedHUDView.swift` |
| Screen lock HUD | `View/Notch/Collapsed/HUDView/Minimal/ScreenLockHUDView.swift` |

### Feature: Mirror
| Responsibility | Current File |
|---|---|
| Camera preview (selfie mirror) | `View/Notch/Expanded/ItemViews/MirrorView.swift` |
| Camera preview NSView wrapper | `View/Common/CameraPreviewView.swift` |
| Mirror defaults (corner radius, auto-start) | `DB/UserDefaults/ExpandedItems/MirrorDefaults.swift` |
| Mirror settings page | `View/Settings/Pages/Expanded/Items/ExpandedMirrorSettingsView.swift` |

### Feature: Bash
| Responsibility | Current File |
|---|---|
| Bash command view | `View/Notch/Expanded/ItemViews/BashView.swift` |
| Bash defaults (command, interval, width) | `DB/UserDefaults/ExpandedItems/BashDefaults.swift` |
| Bash settings page | `View/Settings/Pages/Expanded/Items/ExpandedBashSettingsView.swift` |

### Shared / Common
| Responsibility | Current File |
|---|---|
| Marquee scrolling text | `View/Common/MarqueeTextView.swift` |
| Animated number text | `View/Common/AnimatedNumberTextView.swift` |
| Settings row component | `View/Components/SettingsRow.swift` |
| Generic control view | `View/Notch/Expanded/Controls/GenericControlView.swift` |
| Settings control view | `View/Notch/Expanded/Controls/SettingsControlView.swift` |
| Pin control view | `View/Notch/Expanded/Controls/PinControlView.swift` |
| View extensions (hide, onMultiDrag, glassEffect) | `Utils/Extensions/View.swift` |
| URL extensions | `Utils/Extensions/URL.swift` |
| Optional extensions | `Utils/Extensions/Optional.swift` |
| Date utilities | `Utils/DateUtils.swift` |
| PrimitiveUserDefault wrapper | `Utils/PropertyWrappers/PrimitiveUserDefault.swift` |
| CodableUserDefault wrapper | `Utils/PropertyWrappers/CodableUserDefault.swift` |
| Notch enums (HeightMode) | `Models/Enums/NotchEnums.swift` |
| Display visibility enum | `Models/Enums/NotchDisplayVisibility.swift` |
| Expanded item enum | `Models/Enums/ExpandedNotchItem.swift` |
| Settings shell (NavigationSplitView) | `View/Settings/CorgiSettingsView.swift` |
| General settings page | `View/Settings/Pages/GeneraSettingsView.swift` |
| About page | `View/Settings/Pages/AboutAppView.swift` |
| Collapsed items settings page | `View/Settings/Pages/Collapsed/CollapsedItemsSettingsView.swift` |
| Expanded items settings page | `View/Settings/Pages/Expanded/ExpandedItemsSettingsView.swift` |

## Open questions
- Should the rebuild preserve the current `UserDefaults` key names exactly, or is a migration layer acceptable if it simplifies the architecture?
- Should `Mirror` and `Bash` remain first-class feature modules in the first rebuild pass, or be moved later after the higher-traffic features are stabilized?
- Do you want the rebuild to keep the current settings navigation layout, or is a settings-page reorganization acceptable as long as all controls remain available?
