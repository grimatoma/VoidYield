# VoidYield — Claude Guidelines

## Model selection

Use the cheapest model that can do the job:

- **Haiku** — mechanical tasks with a clear spec: writing GDScript per spec, adding save fields, wiring inputs, boilerplate, config files, SVG generation. If the output is fully determined by the spec, use Haiku.
- **Sonnet** — tasks needing judgment: fitting new systems into existing architecture, non-obvious debugging, multi-file integration work.
- **Opus** — deep design work only: cross-spec audits, resolving contradictions, major architectural decisions.

Default to Haiku for M0–M14 milestone implementation. Most implementation tasks are spec-driven and mechanical.

## Project overview

Godot 4.6.2, GDScript, GL Compatibility renderer, 960×540 base resolution. Top-down 2D active-incremental mining game. Main scene on launch: `res://scenes/ui/main_menu.tscn`.

Design docs live in `docs/` — read `docs/GAME_DESIGN.md` first for the master vision, then the relevant spec in `docs/specs/` before touching any system. The implementation order is in `docs/IMPLEMENTATION_ROADMAP.md` (milestones M0–M14). Ancillary: `docs/VOID_YIELD_GDD.md`, `docs/VOID_YIELD_UI_PRD.md`.

## Repository layout

- `autoloads/` — global singletons registered in `project.godot` `[autoload]`. Load order: `TechTree`, `ProducerData`, `GameState`, `SaveManager`, `AudioManager`, `SettingsManager`, `ColonyManager`, `ConsumptionManager`, `EventLog`. All shared state lives here; UI connects to signals — never poll.
- `scenes/` — runtime scenes grouped by area:
  - `main/` — root `main_scene.tscn` that boots gameplay.
  - `ui/` — `main_menu`, `hud`, `pause_menu`, `options_panel`, `shop_panel`, `tech_tree_panel`, `galaxy_map_panel`, `spaceship_panel`, `resource_quality_inspector`, `mobile_controls`.
  - `world/` — planet-A1 fixtures: `industrial_site`, `harvester_base`, `processing_plant`, `fabricator`, `storage_depot`, `shop_terminal`, `sell_terminal`, `drone_bay`, `launch_pad`, `survey_tool`, `zone_manager`, `game_loop`, `ore_node`, `deposit_node`, `asteroid_field`, `spaceship`.
  - `planet_b/` — second-planet scene (M10+).
  - `player/` — `player.tscn` (`CharacterBody2D`).
  - `drones/` — `scout_drone`, `cargo_drone`, `refinery_drone`, `repair_drone`, `heavy_drone`, plus `drone_bay`, `drone_task_queue`, `fleet_manager`.
- `scripts/` — non-scene code: `interactable.gd` base, `utils/number_format.gd`, `vehicles/` (speeder, vehicle_base), `git_safe_commit.sh`, and Python sprite generators.
- `data/` — gameplay data: `recipes.gd`, `survey_stages.gd`, `tech_tree_data.gd`, `quality_modifiers.gd`, `ore_quality_lot.gd`, plus JSON (`drones.json`, `ship_parts.json`, `upgrades.json`). Prefer extending these over hard-coding.
- `docs/specs/` — 18 spec files (`00_a2_transit` through `17_world_generation`). Each system has exactly one authoritative spec.
- `tests/` — `framework/` (test_runner, test_case, e2e_test_case, image_diff, virtual_input), `unit/`, `e2e/`, `golden/` (PNG references for e2e image diff).
- `assets/`, `design_mocks/`, `tools/` — art, mocks, and Python generators (`gen_iron_ore.py`, `gen_mining_truck.py`, `generate_sprites.py`).
- `addons/TileMapDual` — enabled editor plugin. `addons/godot_mcp` present but not enabled.
- `.github/workflows/web_export.yml` — CI that exports the Web preset and deploys to GitHub Pages on push to `main`.

## Key conventions

- **Save data**: two slots via `autoloads/save_manager.gd` — `user://save.json` (manual, `save_game()` throttled 5 s; `save_game_immediate()` bypasses cooldown) and `user://save_auto.json` (autosave every 60 s). Payload wraps `GameState.get_save_data()` + `TechTree.get_save_data()` under `SAVE_VERSION` ("0.2"); a version bump intentionally wipes incompatible saves. When adding persistent state, extend both `get_save_data()` and `_apply_payload()`.
- **Settings**: `user://settings.cfg` via `autoloads/settings_manager.gd` — separate from save data. Currently persists `music_volume`, `sfx_volume`, `fullscreen`.
- **Input map**: all 20 bindings defined in `project.godot` per spec 16 — never add new keys without checking for conflicts. WASD/Arrows, E (interact), Q, Z, R, T, F, G, L, P, O, B, I, J, Tab, ESC, F11, mouse buttons, scroll.
- **Fullscreen**: F11 toggle, `CANVAS_ITEMS` scaling mode, `DEFAULT_FULLSCREEN=true`.
- **Physics layers** (`project.godot`): 1=player, 2=world, 3=interactables, 4=drones.
- **Art palette**: optimistic retro-futurism — amber `#D4A843`, dark navy `#0D1B3E`, teal accents. Default texture filter is nearest (pixel art).
- **Industrial Site slots**: always enforce slot limits from spec 05 before placing buildings.
- **GameState debug flag**: `GameState.debug_click_mode = true` skips save loading on boot and enables click-through interactions — reset it when shipping test changes.

## Architecture notes

- `GameState` is the single source of truth for player stats, inventory, economy, unlocks. All mutations emit signals (`credits_changed`, `inventory_changed`, `building_constructed`, etc.). UI nodes subscribe to signals in `_ready` — do not read `GameState` fields every frame.
- Interactables extend `scripts/interactable.gd`; the player discovers them via the `interactables` physics layer and publishes `current_interaction_target` through `GameState.interaction_target_changed`.
- Tech unlocks flow: `TechTree.node_unlocked` → `GameState._on_tech_node_unlocked` → survey tier, fleet caps, etc. Add new gated features by listening to `TechTree.node_unlocked`, not by polling `unlocked_tech_nodes`.
- New autoloads must be registered in `project.godot` `[autoload]` and added to `save_manager.gd` payload if they hold persistent state.

## Testing

- Runner entry: `res://tests/run_tests.tscn` → `tests/run_tests.gd` → `tests/framework/test_runner.gd`. It deletes `user://save.json` before running so tests start clean.
- Discovery: every `.gd` under `tests/unit/` and `tests/e2e/`; each `test_*` method is invoked. Exit code `0`=all pass, `1`=any fail. Final line: `[SUMMARY] passed=N failed=M suites=S`.
- CLI flags (pass after `--`): `--unit-only`, `--e2e-only`, `--filter=<substr>`, `--update-golden` (regenerate `tests/golden/*.png` — inspect before committing).
- Windows convenience wrapper: `run_tests.bat [flags]` (expects `Godot_v4.6.2-stable_win64{,_console}.exe` at repo root). On Linux/CI run Godot headless directly: `godot --headless --path . res://tests/run_tests.tscn -- --unit-only`.
- E2E suites use `framework/e2e_test_case.gd` + `virtual_input.gd` for scripted input and `image_diff.gd` against `tests/golden/`.
- When adding a new system, add a unit suite under `tests/unit/test_<system>.gd` mirroring the existing naming. Add an e2e suite only for player-visible flows (see `tests/e2e/test_shop_flow.gd`, `test_sell_and_craft_cuj.gd`).

## Build & deploy

- Web export preset (`Web`) lives in `export_presets.cfg`; thread support is off so GitHub Pages serves without COOP/COEP headers.
- CI workflow `.github/workflows/web_export.yml` runs on push to `main`: caches Godot + templates, runs a 30 s editor import pass, exports to `build/web/`, deploys via `actions/deploy-pages@v4`. Live URL: `https://grimatoma.github.io/VoidYield/`.
- Do not edit `.godot/` (ignored). Do not commit `exports/`, `.vscode/`, `.claude/settings.local.json`, or `*.skill` (see `.gitignore`).

## Working on this repo

- Before touching a system, read its spec in `docs/specs/` — specs are authoritative over any in-code comments.
- Keep UI in `scenes/ui/`, world fixtures in `scenes/world/`, globals in `autoloads/`. Don't colocate state with scenes.
- Prefer `scripts/utils/number_format.gd` for any credit/quantity display so formatting stays consistent.
- Git: develop on the branch specified in task instructions; use `scripts/git_safe_commit.sh "msg"` for a safe add-and-commit flow if running locally.
