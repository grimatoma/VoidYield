# Skill: UI Mock ↔ Implementation Sync

## Purpose

Keep the SVG UI mocks in `ui_mocks/` and the real Godot UI scenes/scripts in `scenes/ui/` in sync. Whenever UI-related code is added, modified, or new game features touch the HUD or panels, run this audit to catch drift and propose updates.

## When to Trigger

Activate this skill **automatically** whenever:
- A file in `scenes/ui/` is created or modified (`.tscn`, `.gd`)
- A file in `ui_mocks/` is created or modified (`.svg`)
- A change in `autoloads/game_state.gd` adds/removes signals, resources, or state that the HUD or panels should display
- A new interactable, panel, or game mechanic is introduced that would need UI representation
- The user asks to add a feature that has UI implications

## Mock ↔ Implementation Mapping

| SVG Mock | Implementation Files | Description |
|---|---|---|
| `01_hud_desktop.svg` | `scenes/ui/hud.tscn`, `scenes/ui/hud.gd` | Main HUD — resource rail, credits, inventory, storage bar, interaction prompt, mining progress |
| `02_hud_mobile.svg` | `scenes/ui/mobile_controls.tscn`, `scenes/ui/mobile_controls.gd` | Mobile joystick + context action button |
| `03_shop_panel.svg` | `scenes/ui/shop_panel.tscn`, `scenes/ui/shop_panel.gd` | Shop terminal — drone/upgrade/build tabs, cost pills, owned states |
| `04_sell_terminal.svg` | *(not yet implemented)* | Sell terminal — pool readout, segmented bar, SELL ALL button, auto-sell toggle |
| `05_storage_depot.svg` | *(not yet implemented — HUD has storage bar only)* | Storage depot panel — capacity, deposit button, expansion upgrades |
| `06_interaction_prompts.svg` | `scenes/ui/hud.tscn` (`InteractionPrompt` node) | World-space `[E] VERB` prompts |
| `07_pause_settings.svg` | *(not yet implemented)* | Pause overlay — resume, settings, save & quit, sliders |
| `08_main_menu.svg` | *(not yet implemented)* | Main menu — title, button stack, version string |
| `09_ship_bay.svg` | `scenes/ui/spaceship_panel.tscn`, `scenes/ui/spaceship_panel.gd` | Ship assembly — 5 progression stages, component list, launch button |
| `10_galaxy_map.svg` | *(not yet implemented)* | Galaxy map — asteroid nodes, routes, legend, travel button |
| `11_cargo_dock.svg` | *(not yet implemented)* | Cargo dock — active routes list, route editor form |

## Audit Procedure

When this skill is triggered, perform the following steps:

### Step 1 — Identify the Changed Scope

Determine which mock(s) and implementation file(s) are affected by the current change. Use the mapping table above.

### Step 2 — Extract Elements from Both Sides

**From the SVG mock**, extract:
- All UI elements shown (labels, buttons, bars, counters, icons, toggles, panels)
- Visual states depicted (disabled, locked, active, affordable/unaffordable, installed, etc.)
- Layout structure (positions, groupings, hierarchy)
- Text content and labels
- Color tokens used (cross-reference with `ui_mocks/_shared.md`)

**From the Godot implementation**, extract:
- All nodes in the `.tscn` scene tree
- All `@onready` references and signals connected in `.gd`
- All dynamic UI updates (what data drives what label/bar/button)
- Visual states handled in code (visibility toggling, color changes, disabled states)

### Step 3 — Diff and Classify Gaps

Compare the two sides and classify each discrepancy:

| Gap Type | Description | Example |
|---|---|---|
| **MOCK_MISSING** | Implementation has a feature/element not shown in any mock | HUD shows `KRYSITE` label but no mock depicts it |
| **IMPL_MISSING** | Mock shows a feature/element not yet in the implementation | Mock `04_sell_terminal.svg` exists but no `sell_terminal.tscn` |
| **STYLE_DRIFT** | Element exists in both but colors, sizes, or layout diverge | Mock uses `#d4a843` amber but implementation uses `Color(0.65, 0.35, 1.0)` purple |
| **STATE_MISSING** | Mock depicts a state (e.g., "locked", "full") the implementation doesn't handle, or vice versa | Mock shows auto-sell locked toggle but implementation has no auto-sell logic |
| **LABEL_DRIFT** | Text/label content differs between mock and implementation | Mock says `SHOP TERMINAL`, implementation says `SHOP` |
| **STRUCTURE_DRIFT** | Node hierarchy / layout approach differs significantly | Mock has tabs (DRONES/UPGRADES/BUILD), implementation has no tab system |

### Step 4 — Report Findings to User

Present findings as a structured table:

```
## UI Sync Audit Results

### [Screen Name] — [mock file] ↔ [impl files]

| # | Gap Type | Element | Mock Shows | Implementation Has | Recommendation |
|---|----------|---------|------------|-------------------|----------------|
| 1 | LABEL_DRIFT | Title | "SHOP TERMINAL" | "SHOP" | Update .tscn title to match mock |
| 2 | MOCK_MISSING | Krysite label | (not depicted) | Shown when rare > 0 | Add to mock 01 resource rail |
| ... | ... | ... | ... | ... | ... |
```

### Step 5 — Propose Changes

For each gap, propose ONE of the following actions **and ask the user to decide**:

1. **Update the mock** — Provide the specific SVG elements to add/modify, matching the existing salvagepunk style tokens from `_shared.md`. Show the proposed SVG snippet.

2. **Update the implementation** — Describe the Godot scene/script changes needed to match the mock.

3. **Defer** — Mark as known drift, acceptable for now (e.g., the mock is for a future version like v0.3+).

4. **Both need updating** — Sometimes neither side is "right" and a design decision is needed. Flag these clearly.

**Always ask the user before making changes.** Never silently modify a mock or implementation to match the other.

## Design Tokens Reference

When proposing SVG additions, use these tokens from `ui_mocks/_shared.md`:

```
bg.console  #2a2a2e    — panel backgrounds
bg.deep     #1a1a1d    — modal scrim, deepest recesses
text.pri    #d4a843    — amber readouts, primary labels
text.sec    #a88a4a    — dimmed/disabled labels
warn        #8b3a2a    — rust red errors
good        #7cb87c    — pale green success
info        #5a8fa8    — steel blue info
rim         #4a4a50    — panel borders/rivets
shadow      #15151a    — inner shadow
```

All SVGs are 960×540 logical, pixel-crisp (`shape-rendering="crispEdges"`), monospace font-family.

## SVG Style Rules for Proposed Changes

When generating SVG snippets for mock updates:
- Use `shape-rendering="crispEdges"` and `font-family="monospace"`
- Rivet dots at panel corners: 3×3 px, `#d4a843`
- Panel headers: full-width `bg.deep` (#15151a) bar with amber title text
- Close buttons: 18×18 rect, `#2a2a2e` fill, `#8b3a2a` stroke, "X" text
- Buttons: `#2a2a2e` fill, `#d4a843` stroke for affordable, `#8b3a2a` for unaffordable
- Progress bars: segmented cells, not smooth fills
- Locked/disabled elements: `opacity="0.4"` or `opacity="0.55"`
- Label footer banner: `#1a1a1d` bar at y=516, 24px tall, `#a88a4a` text at font-size 10

## Implementation Style Rules

When suggesting Godot implementation changes:
- Colors use Godot `Color(r, g, b, a)` format (0.0–1.0)
- Convert hex to Godot: `#d4a843` → `Color(0.83, 0.66, 0.27, 1.0)`
- UI nodes follow existing patterns: `PanelContainer` → `MarginContainer` → `VBoxContainer` → content
- Slide-in panels use tweened `offset_left` from offscreen (960+) to visible position
- Signal connections go through `GameState` autoload
- Label bounce animation: scale 1.0 → 1.2 → 1.0 over ~200ms

## Priority Rules

- **P0 mocks (01–08)** should be kept tightly in sync with implementation
- **P1 mocks (09–10)** should be synced when those features are actively developed
- **P2 mocks (11–12)** may have known drift; flag but don't block on them
- New features ALWAYS need a mock check — if no mock exists, propose creating one
