# Task Plan: CorgiNotch Rebuild Planning

## Goal
Produce an implementation-ready rebuild plan for `CorgiNotch` that simplifies and atomizes the codebase, keeps all current features intact, and defines a clearer architecture and file structure without writing implementation code yet.

## Current Phase
Complete

## Phases
### Phase 1: Requirements & Baseline Audit
- [x] Capture the user's rebuild goals and constraints
- [x] Move all planning markdown into `docs/`
- [x] Audit the current app structure and feature surface
- **Status:** complete

### Phase 2: Reference Research
- [x] Study the linked notch projects for structural and UX patterns
- [x] Research relevant macOS APIs and architectural constraints
- [x] Record actionable findings in `docs/findings.md`
- **Status:** complete

### Phase 3: Target Architecture Planning
- [x] Define a simpler feature-oriented module/file structure
- [x] Map current features to the new architecture
- [x] Identify shared infrastructure that should be centralized
- **Status:** complete

### Phase 4: Task Decomposition
- [x] Break the rebuild into ordered implementation tasks
- [x] Identify migration risks and validation requirements
- [x] Produce a planning-only rebuild checklist in `docs/rebuild-plan.md`
- **Status:** complete

### Phase 5: Planning Delivery
- [x] Review the planning docs for completeness
- [x] Summarize the proposed rebuild direction and risks
- [x] Deliver the planning package to the user
- **Status:** complete

## Key Questions
1. Which parts of the current structure make the app hard to reason about or maintain?
2. How should the app be reorganized so each feature is more atomic while preserving cross-feature behavior?
3. Which macOS APIs and project patterns should guide the rebuild for notch windows, media state, drag/drop, AirDrop, brightness, volume, and settings control?

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| Keep this turn in planning mode only | The user explicitly asked for planning and no implementation |
| Store planning markdown in `docs/` | The user explicitly wants findings, plans, and tasks kept there |
| Preserve all current features and avoid adding new ones | The rebuild is for clarity and optimization, not scope expansion |
| Use the already-renamed `CorgiNotch` codebase as the rebuild baseline | The forked project now builds and represents the current feature set to preserve |
| Propose a feature-oriented architecture with explicit app-shell and infrastructure layers | This best matches the user's simplicity goal and the reference/API research |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|

## Notes
- Prefer feature-oriented planning over class-by-class migration notes
- The settings surface must retain full control over existing functionality
- Every planning update should be written back into the markdown files under `docs/`
