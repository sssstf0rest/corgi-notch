# Task Plan: Settings Window Foreground Fix

## Goal
Inspect the live `CorgiNotch` repository and current `docs/` state, summarize the project purpose/stack/architecture/dependencies/build flow, and fix the expanded-notch settings icon behavior so the settings window always comes to the foreground when opened.

## Current Phase
Phase 4 complete

## Phases
### Phase 1: Live Repository Audit
- [x] Inspect the current source tree and the markdown files under `docs/`
- [x] Capture project purpose, tech stack, architecture, dependency structure, and build/run flow from live code
- [x] Record repo-state findings for this session
- **Status:** complete

### Phase 2: Settings Window Path Analysis
- [x] Trace the expanded-notch settings icon click path
- [x] Trace other settings entry points for shared behavior
- [x] Identify why the settings window can open behind other windows
- **Status:** complete

### Phase 3: Foreground Activation Fix
- [x] Introduce a shared foreground-opening path for settings
- [x] Update the expanded-notch settings icon to use the shared path
- [x] Apply the same fix to other settings entry points that should behave consistently
- **Status:** complete

### Phase 4: Verification and Docs
- [x] Build the app and confirm the settings flow compiles cleanly
- [x] Update `docs/findings.md` and `docs/progress.md` with the implemented fix
- [x] Summarize repository understanding and the fix result
- **Status:** complete

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Use the live source tree, not prior historical docs, as the implementation source of truth | The `docs/` folder currently only contains `progress.md`, so source inspection is required for an accurate repository model |
| Restore `docs/task_plan.md` and `docs/findings.md` for this task | The user wants markdown progress kept in `docs/`, and the current repo no longer has the full planning set |
| Fix the settings bug at the settings-window opening layer, not only inside the settings view | The foreground issue happens when reopening an existing settings window, so relying only on the settings scene’s `.task` is insufficient |
| Use `NSApp.activate(ignoringOtherApps: true)` plus explicit window ordering | The first build showed `NSRunningApplication.activateIgnoringOtherApps` is deprecated and ineffective on macOS 14+, so the foreground fix should rely on the active AppKit API |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|

## Follow-up Task: Custom Step Zero Floor Fix
- [x] Inspect the intercepted media-key handlers for Audio and Brightness
- [x] Identify why custom step sizes can display `0%` while the real system value remains slightly above zero
- [x] Snap downward residual values that would round to `0%` to a real floor
- [x] Ensure output audio is muted when the custom decrement path reaches zero
- [x] Rebuild and record the result in `docs/`

## Follow-up Task: Sparkle Release Flow
- [x] Inspect the current updater wiring and confirm why GitHub Releases alone are insufficient
- [x] Identify the missing Sparkle requirements for this repo: real feed URL, public key injection, signed appcast generation, and release hosting
- [x] Configure the app to use a real Sparkle feed and injectable public key
- [x] Add release automation and maintainer scripts for publishing Sparkle updates
- [x] Document the one-time setup and ongoing release process in `docs/`
- [x] Verify the updated configuration and scripts
