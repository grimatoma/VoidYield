# VoidYield Playtest Report
**Date:** 2026-04-18
**Test mode:** Headless (unit + E2E)
**debug_click_mode:** true
**Starting credits:** 500 | **Starting ore:** 10,000 (all types)

## Executive Summary

329 of 356 tests pass across 35 suites — overall unit health is strong. Two distinct root causes account for all 27 failures: (1) GDScript `class_name`-based cross-file inheritance breaks when the main scene is loaded dynamically from within the test runner (`extends Interactable`, `NumberFormat`, `ScoutDrone` all fail to resolve), cascading into 21 E2E failures; and (2) the fabricator unit tests reference a recipe ID (`craft_drill`) that was removed from `data/recipes.gd`, causing 6 unit failures. Cold start (`--quit-after 3`) is fully clean. The core mine→deposit→sell loop works end-to-end. Confidence in the unit layer is high; the E2E layer is blocked but for a well-understood, fixable reason.

---

## Test Results

### Unit Tests

| Suite | Pass | Fail | Notes |
|-------|------|------|-------|
| test_audio_manager | 9 | 0 | |
| test_cargo_drone | 6 | 0 | |
| test_colony_manager | 22 | 0 | SCRIPT ERRORs logged (`.new()` on Node), tests pass via workaround |
| test_deposit_node | 10 | 0 | `OreQualityLot` type annotation compile error logged, tests pass via fallback |
| test_drone_bay | 10 | 0 | `DroneTaskQueue.enqueue` type mismatch logged, tests pass |
| test_drone_task_queue | 8 | 0 | |
| test_event_log | 7 | 0 | |
| **test_fabricator** | **7** | **6** | `craft_drill` recipe ID missing from recipes.gd |
| test_fleet_manager | 6 | 0 | ZoneManager type errors logged, tests pass |
| test_game_loop | 3 | 0 | |
| test_save_manager | 12 | 0 | |
| test_storage_depot | 16 | 0 | |
| test_survey_tool | 6 | 0 | |
| test_tech_tree | 16 | 0 | |
| test_zone_manager | 5 | 0 | ZoneManager type errors logged, tests pass |
| *(other unit suites)* | ~184 | 0 | game_state, market, quality_modifier, producer_data, ship_part, etc. |

**Unit total: ~323 passed, 6 failed**

### E2E Tests

| Test | Result | Notes |
|------|--------|-------|
| test_galaxy_map_flow / test_cannot_travel_to_current_location | FAIL | main_scene null (Interactable cascade) |
| test_galaxy_map_flow / test_cannot_travel_to_locked_planet | FAIL | same |
| test_galaxy_map_flow / test_cuj_craft_launch_select_travel | FAIL | same |
| test_galaxy_map_flow / **test_cuj_launch_pad_return_to_a1** | **PASS** | doesn't open galaxy_map panel |
| test_galaxy_map_flow / test_galaxy_map_golden | FAIL | screenshot null |
| test_galaxy_map_flow / test_opens_and_shows_three_bodies | FAIL | panel null |
| test_galaxy_map_flow / test_select_body_updates_action_panel | FAIL | panel null |
| test_galaxy_map_flow / test_travel_to_planet_b_transitions_world | FAIL | panel null |
| test_main_boot / test_hud_and_panels_registered | FAIL | HUD fails to load (NumberFormat cascade) |
| test_main_boot / **test_initial_current_planet_is_a1** | **PASS** | game_state only, no scene |
| test_main_boot / test_initial_hud_matches_golden | FAIL | screenshot null |
| test_main_boot / test_player_spawns_in_asteroid_field | FAIL | scene not loaded |
| test_sell_and_craft_cuj / **test_core_loop_mine_deposit_sell** | **PASS** | data layer only, no UI panels |
| test_sell_and_craft_cuj / test_craft_ship_part_via_panel | FAIL | spaceship panel null |
| test_shop_flow / test_opening_shop_panel_shows_upgrades_tab | FAIL | panel null |
| test_shop_flow / test_purchasing_upgrade_deducts_credits | FAIL | panel null |
| test_shop_flow / test_resources_tab_sells_from_carried_ore | FAIL | panel null |
| test_shop_flow / test_shop_panel_golden_upgrades_tab | FAIL | screenshot null |
| test_spaceship_flow / test_launch_disabled_until_ship_ready | FAIL | panel null |
| test_spaceship_flow / test_launch_enables_after_all_parts_crafted | FAIL | panel null |
| test_spaceship_flow / test_launch_opens_galaxy_map | FAIL | panel null |
| test_spaceship_flow / test_spaceship_panel_golden | FAIL | screenshot null |
| test_virtual_click_cuj / **test_click_over_open_panel_is_ignored** | **PASS** | doesn't require panels to open |
| test_virtual_click_cuj / test_click_shop_terminal_opens_shop_panel | FAIL | panel null |

**E2E total: 4 passed, 21 failed**

---

## Failures

### 1. [BLOCKER] E2E: `extends Interactable` / `NumberFormat` / `ScoutDrone` class_name resolution fails during dynamic scene load

**Affected tests:** All 21 E2E failures

**Error messages:**
```
SCRIPT ERROR: Parse Error: Could not find base class "Interactable".
  at: GDScript::reload (res://scenes/world/ore_node.gd:1)
SCRIPT ERROR: Parse Error: Identifier "NumberFormat" not declared in the current scope.
  at: GDScript::reload (res://scenes/ui/hud.gd
SCRIPT ERROR: Parse Error: Could not find type "ScoutDrone" in the current scope.
  at: GDScript::reload (res://scenes/ui/shop_panel.gd:688)
```

**Affected scripts:**
- `scenes/world/ore_node.gd` — `extends Interactable`
- `scenes/world/sell_terminal.gd` — `extends Interactable`
- `scenes/world/shop_terminal.gd` — `extends Interactable`
- `scenes/world/drone_bay.gd` — `extends Interactable`
- `scenes/world/spaceship.gd` — `extends Interactable`
- `scenes/world/launch_pad.gd` — `extends Interactable`
- `scenes/player/player.gd` — uses `Interactable` as a type annotation
- `scenes/main.gd` — uses `Interactable` as a type annotation
- `scenes/ui/hud.gd` — uses `NumberFormat` (from `scripts/utils/number_format.gd`)
- `scenes/ui/shop_panel.gd` — uses `ScoutDrone` type (from `scenes/drones/scout_drone.gd`)

**Likely cause:** GDScript's global class name registry resolves correctly during normal startup (cold-start `--quit-after 3` is fully clean). When the E2E framework calls `load("res://scenes/main.tscn")` at runtime after the test runner scene is already active, GDScript re-parses dependent scripts and cannot resolve class names registered via `class_name`. This is the same class of issue addressed in the recent `fix(types)` commit.

**Fix:** Replace `class_name`-based references with path-based preloads or extends paths:
- `extends Interactable` → `extends "res://scripts/interactable.gd"` (6 scripts)
- `NumberFormat.format_number(...)` → `preload("res://scripts/utils/number_format.gd").format_number(...)` in hud.gd
- `ScoutDrone` type references → `preload("res://scenes/drones/scout_drone.gd")` at top of shop_panel.gd

---

### 2. [UNIT] test_fabricator: `craft_drill` recipe does not exist in recipes.gd

**Affected tests:** 6 (test_can_run_true_with_inputs, test_collect_output_removes_from_buffer, test_cycle_completed_signal_fires, test_output_buffer_capped_at_10, test_tick_advances_progress, test_tick_completes_cycle_after_duration)

**Error detail:**
```
✗ test_can_run_true_with_inputs
    └ Should run with all inputs — expected true  got false
✗ test_tick_advances_progress
    └ Should advance progress — expected 0.0 > 0.0
✗ test_tick_completes_cycle_after_duration
    └ Should have output — expected 0 > 0
```

**Cause:** `tests/unit/test_fabricator.gd` sets recipe `"craft_drill"` with inputs `steel_bar: 4, common: 2` and expects output `"basic_drill"`. Neither the recipe ID nor the output key exist in `data/recipes.gd`. The fabricator's `can_run()` returns false because `RECIPES.ALL.has("craft_drill")` is false, so nothing executes.

**Fix:** Update `tests/unit/test_fabricator.gd` to use the real `"craft_surveyor"` recipe:
- inputs: `steel_bar: 4, crystal_lattice: 2`
- output: `surveyor_unit: 1`
- time: `20.0s` (unchanged)

Replace all 3 occurrences of `"craft_drill"` → `"craft_surveyor"`, `"common"` → `"crystal_lattice"`, `"basic_drill"` → `"surveyor_unit"`.

---

## Warnings

### Non-fatal script errors (tests pass despite these)

| Location | Error | Impact |
|----------|-------|--------|
| test_zone_manager.gd, test_fleet_manager.gd | `ZoneManager.create_zone` — MockDepot (RefCounted) not a subclass of expected Node type | Tests pass via SCRIPT ERROR recovery; MockDepot should extend Node |
| test_colony_manager.gd | colony_manager extends Node, `.new()` fails but add_child path works | Benign; all 22 tests green |
| test_deposit_node.gd | `OreQualityLot` type annotation causes compile error in test file import | Benign; tests execute via GDScript fallback |
| test_drone_bay.gd | `DroneTaskQueue.enqueue` called with String instead of Object | Tests pass; type safety gap in test mock |

### Missing .ctex import cache (texture errors in E2E output)

All building/ground sprites exist on disk but their Godot import cache (`.godot/imported/*.ctex`) is stale. These errors appear only in E2E test output and are not the primary cause of failures — the Interactable parse error fires first.

**Affected:** `storage_depot.png`, `sell_terminal.png`, `shop_terminal.png`, `drone_bay.png`, `spaceship.png`, `launch_pad.png`, `tile_space_bg.png`, `tile_outpost_floor.png`, `tile_asteroid.png`, `rock_small/medium/large.png`, `player_se.png`

**Fix:** Open the project in the Godot editor once to rebuild import cache.

### Resource leaks at exit

```
WARNING: 59 RIDs of type "CanvasItem" were leaked.
WARNING: ObjectDB instances leaked at exit.
ERROR: 7 resources still in use at exit.
```

Cosmetic in headless test context; not causing failures.

### UID mismatch

```
WARNING: res://scenes/main.tscn:3 - ext_resource, invalid UID: uid://cc7d71cfqk8ov
```

Benign; Godot falls back to text path. Re-save `main.tscn` in editor to regenerate UID.

---

## Game Loop Assessment

### Core Loop (mine → deposit → sell → credits)
**PASS** — `test_core_loop_mine_deposit_sell` passes. The data layer (game_state, storage_depot, sell transactions) is fully functional end-to-end.

### Shop / Upgrade Flow
**FAIL** — All shop panel tests fail. The shop panel cannot open because `main.tscn` fails to load in the E2E context (Interactable cascade). Underlying upgrade data/deduction logic is likely sound based on unit coverage elsewhere.

### Drone Deployment
**PARTIAL** — All drone unit tests pass (drone_bay, drone_task_queue, fleet_manager, zone_manager, cargo_drone — 40+ tests green). The E2E test for clicking the shop terminal to open the drone assignment UI fails. Data-layer drone logic is complete and tested.

### Spaceship Crafting
**FAIL** — All spaceship panel tests fail (null panel from E2E cascade). Ship part data and quality modifier unit tests pass (M9a milestone green). The crafting data layer is solid; only the UI integration is blocked.

### Galaxy Map / Travel
**PARTIAL** — `test_cuj_launch_pad_return_to_a1` passes (uses game_state / signal path that doesn't open the galaxy map panel UI). All panel-dependent travel tests fail from the E2E cascade. `game_state.current_planet` logic appears sound.

---

## Debug Harness Notes

- **Starting ore:** `player_carried_ore = 10,000`, `storage_ore = 10,000` — skips all early mining grind. 14 TODO comments in `autoloads/game_state.gd` mark values to reset before release.
- **Starting credits:** `credits = 500` — enough to buy some upgrades immediately.
- **debug_click_mode = true** (`game_state.gd:86`) — proximity check bypassed; any click on an interactable triggers it instantly. Must be set to `false` before player-facing builds.
- **max_fleet_size = 2** (TODO: restore to 1) — extra drone slot active during testing.
- **storage_capacity = 10,000** (TODO: restore to 50) — depot never fills during tests.
- Multiple ore subtypes (rare, aethite, voidstone, shards) pre-loaded to 2,000 units each.

---

## Known Issues / Bugs Found

1. **E2E test suite entirely blocked** — `extends Interactable` (and `NumberFormat`, `ScoutDrone`) class_name resolution fails when main scene is loaded dynamically. Affects 21 tests across 6 E2E suites.

2. **test_fabricator uses deleted recipe** — `"craft_drill"` recipe was removed from `data/recipes.gd` but tests were not updated. 6 fabricator unit tests fail.

3. **Stale .godot import cache** — `.ctex` files for 13 sprites are missing or stale. Causes spurious ERRORs in headless runs; does not independently fail any test.

4. **ZoneManager.create_zone rejects RefCounted mocks** — Tests pass a RefCounted MockDepot where a Node is required. SCRIPT ERRORs logged but tests recover; real API enforces Node type at runtime.

5. **main.tscn UID mismatch** — Stale ext_resource UID; Godot falls back to text path. Cosmetic.

---

## Recommended Next Steps

1. **Fix E2E class_name cascade** *(unblocks 21 tests)*: In the ~10 scripts that use `extends Interactable`, `NumberFormat`, or `ScoutDrone` by class name, replace with path-based preloads. Same pattern as the recent `fix(types)` commits.

2. **Fix test_fabricator recipe references** *(fixes 6 tests, ~5 line change)*: Replace `"craft_drill"` → `"craft_surveyor"`, `"common"` → `"crystal_lattice"`, `"basic_drill"` → `"surveyor_unit"` in `tests/unit/test_fabricator.gd`.

3. **Rebuild import cache**: Open the project once in the Godot editor to regenerate `.godot/imported/*.ctex` files.

4. **Reset debug values before next public playtest**: 14 TODO-marked values in `game_state.gd` — especially `debug_click_mode = false`, starting resource values to 0, `storage_capacity = 50`, `max_fleet_size = 1`.

5. **Fix MockDepot in zone/fleet tests to extend Node** — eliminates persistent ZoneManager SCRIPT ERROR noise. Low urgency since tests pass.
