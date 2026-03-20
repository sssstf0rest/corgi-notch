# Rebuild Architecture

## Objective
Rebuild `CorgiNotch` into a simpler, more atomic macOS app structure while preserving all current behavior and keeping the settings experience as the complete control surface for the app.

## Design Principles
- Preserve feature parity first; do not redesign behavior during the rebuild.
- Organize by feature ownership before technical type.
- Keep AppKit/private-framework/windowing code isolated from feature UI.
- Keep the settings UI unified, but make each feature own its own settings state and settings views.
- Prefer small modules with obvious responsibilities over shared singletons that mutate from everywhere.

## Proposed Layers

### 1. App Shell
Owns app startup, menu bar scene, settings scene, app lifecycle, and dependency composition.

Suggested responsibilities:
- `CorgiNotchApp`
- app delegate / launch orchestration
- menu bar shell
- settings shell entry
- dependency/environment composition

### 2. Runtime Infrastructure
Owns platform-specific and notch-specific mechanics that features depend on but should not reimplement.

Suggested responsibilities:
- notch window/panel creation
- space/full-screen/lock-screen window behavior
- screen/notch geometry
- private-framework adapters
- Objective-C bridge wrappers
- persistence primitives and storage adapters
- shared drag/drop and sharing adapters

### 3. Feature Modules
Each existing feature owns its views, settings state, persistence model, and services/coordinators.

Suggested feature modules:
- `NotchPresentation`
- `NowPlaying`
- `FileShelf`
- `AirDrop`
- `HUD/Audio`
- `HUD/Brightness`
- `HUD/Power`
- `HUD/Media`
- `Mirror`
- `Bash`
- `AppSettings`

### 4. Shared UI
Holds reusable view primitives, styling, assets, and lightweight shared models that are not feature-specific.

Suggested responsibilities:
- shared controls
- shared shapes/layout helpers
- app theme/colors/icons
- common modifiers

## Proposed Folder Structure

```text
CorgiNotch/
  App/
    CorgiNotchApp.swift
    CorgiAppDelegate.swift
    AppManager.swift
    UpdaterViewModel.swift
    Settings/
      CorgiSettingsView.swift          # navigation shell only
      Pages/
        GeneraSettingsView.swift
        AboutAppView.swift
        NotchSettingsView.swift
  Infrastructure/
    CorgiNotch-Bridging-Header.h
    Windowing/
      NotchManager.swift
      CorgiWindow.swift                # CorgiPanel (NSPanel subclass)
      NotchShape.swift
      NotchUtils.swift
    SpaceManagement/
      NotchSpaceManager.swift          # CGSSpace for all-spaces
      WindowManager.swift              # SkyLight for lock screen
    SystemAdapters/
      Audio/
        AudioInput.h/.m                # ObjC bridge
        AudioOutput.h/.m               # ObjC bridge
        VolumeManager.swift
      Brightness/
        Brightness.h/.m                # ObjC bridge
      Power/
        PowerStatus.h/.m               # ObjC bridge
        PowerManager.swift
      Media/
        NowPlaying.swift               # MediaRemote adapter
        MediaKeyManager.swift
        Libs/                          # MediaRemoteAdapter.framework, mediaremote-adapter.pl
      Sharing/
        AirDropManager.swift
    Persistence/
      PropertyWrappers/
        PrimitiveUserDefault.swift
        CodableUserDefault.swift
  Features/
    AppSettings/
      AppDefaults.swift
      CorgiDefaultsManager.swift
      CollapsedItemsSettingsView.swift
      ExpandedItemsSettingsView.swift
    NotchPresentation/
      NotchDefaults.swift
      HapticsManager.swift
      Views/
        NotchView.swift
        CollapsedNotchView.swift
        OnlyNotchView.swift
        ExpandedNotchView.swift
        NotchHomeView.swift
        NotchOptionsView.swift
        Controls/
          GenericControlView.swift
          SettingsControlView.swift
          PinControlView.swift
      ViewModels/
        NotchViewModel.swift
        CollapsedNotchViewModel.swift
        ExpandedNotchViewModel.swift
        NotchSettingsViewModel.swift
    NowPlaying/
      Models/
        NowPlayingMediaModel.swift
      Views/
        NowPlayingDetailView.swift
        NowPlayingHUDLeftView.swift
        NowPlayingHUDRightView.swift
      Settings/
        NowPlayingDefaults.swift
        ExpandedNowPlayingSettingsView.swift
    FileShelf/
      Models/
        ShelfFileGroupModel.swift
      Views/
        FileShelfView.swift
        ShelfFileGroupView.swift
        FileShelfControlView.swift
      Settings/
        ShelfDefaults.swift
    HUD/
      Shared/
        HUDDefaultsProtocol.swift
        HUDPropertyModel.swift
        HUDEnums.swift
        MinimalHUDView.swift
        MinimalHUDLeftView.swift
        MinimalHUDRightView.swift
        ProgressHUDView.swift
        NotchedHUDView.swift
        ScreenLockHUDView.swift
      Audio/
        HUDAudioInputDefaults.swift
        HUDAudioOutputDefaults.swift
        AudioDeviceHUDView.swift
        HUDAudioSettingsView.swift
        HUDAudioSettingsViewModel.swift
      Brightness/
        HUDBrightnessDefaults.swift
        HUDBrightnessSettingsView.swift
        HUDBrightnessSettingsViewModel.swift
      Power/
        HUDPowerDefaults.swift
        PowerHUDView.swift
        HUDPowerSettingsView.swift
      Media/
        HUDMediaDefaults.swift
        HUDMediaSettingsView.swift
    Mirror/
      Views/
        MirrorView.swift
      Settings/
        MirrorDefaults.swift
        ExpandedMirrorSettingsView.swift
    Bash/
      Views/
        BashView.swift
      Settings/
        BashDefaults.swift
        ExpandedBashSettingsView.swift
  Shared/
    UI/
      AnimatedNumberTextView.swift
      CameraPreviewView.swift
      MarqueeTextView.swift
      MultiDragPreviewSource.swift
      SettingsRow.swift
    Models/
      NotchEnums.swift
      NotchDisplayVisibility.swift
      ExpandedNotchItem.swift
    Extensions/
      View.swift
      URL.swift
      Optional.swift
      DateUtils.swift
    Assets/
      CorgiNotch.swift               # asset/color definitions
      CorgiAssets.xcassets/
      Lotties/
```

**Status:** Implemented and build-verified (2026-03-20).

## Feature Ownership Model

### App Shell
- Menu bar extra
- settings scene hosting
- launch-time bootstrapping

### NotchPresentation
- notch expand/collapse state
- hover/tap interaction policy
- notch composition and layout
- presentation-only view models

### NowPlaying
- media listener/service wrapper
- now playing state
- compact and expanded UI
- settings for displayed metadata and behavior

### FileShelf
- dropped-file ingestion
- file grouping state
- shelf UI and persistence if retained

### AirDrop
- share-service integration
- outbound sharing flow from shelf or relevant feature surfaces

### HUD Modules
- one module per HUD domain: audio, brightness, power, media
- each module owns defaults, settings UI, and event-to-presentation mapping

### Mirror
- mirror-specific view/state/settings

### Bash
- bash item state/settings/view

## Settings Strategy
- Keep one unified settings shell under `App/Settings`.
- Compose settings pages from feature modules.
- Each feature exports:
  - a settings state object
  - one or more settings views/sections
  - a persistence boundary
- The shell is responsible for navigation only, not feature logic.

## Rebuild Rules
- Do not change user-facing behavior unless required to preserve correctness.
- Do not introduce new features.
- Keep private-framework and bridge code isolated in infrastructure.
- Remove placeholder abstractions that do not add value.
- Validate feature parity after each module migration.

## Main Risks
- Notch window behavior across multiple displays, full-screen apps, and lock-screen placement can regress easily.
- Drag/drop and AirDrop are cross-cutting and should be separated carefully.
- Music/Now Playing behavior depends on platform/private APIs and event timing.
- Current defaults are tightly shared; splitting them requires preserving stored keys or providing a safe migration plan.
