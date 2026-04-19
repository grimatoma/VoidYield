# VoidYield — Claude Guidelines

## Model selection

Use the cheapest model that can do the job:

- **Haiku** — mechanical tasks with a clear spec: writing GDScript per spec, adding save fields, wiring inputs, boilerplate, config files, SVG generation. If the output is fully determined by the spec, use Haiku.
- **Sonnet** — tasks needing judgment: fitting new systems into existing architecture, non-obvious debugging, multi-file integration work.
- **Opus** — deep design work only: cross-spec audits, resolving contradictions, major architectural decisions.

Default to Haiku for M0–M14 milestone implementation. Most implementation tasks are spec-driven and mechanical.

## Project overview

Godot 4.6.2, GDScript, GL Compatibility renderer, 960×540 base resolution.

Design docs live in `docs/` — read `docs/GAME_DESIGN.md` first for the master vision, then the relevant spec in `docs/specs/` before touching any system. The implementation order is in `docs/IMPLEMENTATION_ROADMAP.md`.

## Key conventions

- Save data: `user://savegame.json` via `autoloads/save_manager.gd`
- Settings: `user://settings.cfg` via `autoloads/settings_manager.gd`
- Input map: all 20 bindings defined in `project.godot` per spec 16 — never add new keys without checking for conflicts
- Fullscreen: F11 toggle, `CANVAS_ITEMS` scaling mode, `DEFAULT_FULLSCREEN=true`
- Art palette: optimistic retro-futurism — amber `#D4A843`, dark navy `#0D1B3E`, teal accents
- Industrial Site slots: always enforce slot limits from spec 05 before placing buildings
