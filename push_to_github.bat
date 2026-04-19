@echo off
REM VoidYield — commit all outstanding changes and push to GitHub
REM Double-click this when you get back to your computer.

cd /d "%~dp0"

echo Clearing stale git locks (left by Godot editor)...
if exist ".git\HEAD.lock" del /f ".git\HEAD.lock"
if exist ".git\index.lock" del /f ".git\index.lock"
if exist ".git\objects\maintenance.lock" del /f ".git\objects\maintenance.lock"

echo.
echo Staging all changes...
git add -A

echo.
echo Committing everything...
git commit -m "docs: full game design + spec architecture + CI/CD (v0.4)

Design documentation (docs/):
- GAME_DESIGN.md v0.4 master (vision, pillars, 5-phase arc, system map, reading guide)
- 18 spec files covering all game systems, each with Dependencies + Implementation Notes

Specs (docs/specs/):
  00_a2_transit        - transit asteroid, Gas Depot, A3 unlock role
  01_resource_quality  - SWG-style ore quality attributes (BER formula + FL term)
  02_surveying         - 4-stage scan, deposit journal, survey markers
  03_harvesters        - BER formula with FL, deposit slots table, fuel/hopper loops
  04_drone_swarm       - 3-tier control, Repair Drone added, [B] key fix
  05_factories         - Processing Plant/Fabricator/Assembly Complex, power system
  06_consumption       - crew tier cascade, 4 starting Pioneers, 90s growth cycle
  07_logistics         - ships BUILT at Launchpad, Repair Drone wired, 20 units/trip
  08_vehicles          - Rover/Speeder/Shuttle, Planet C Rocket Fuel note
  09_planets           - A1/B/C identities, Atmospheric Water Extractor, Warp Gate
  10_spacecraft        - component assembly, naming distinction fix
  11_tech_tree         - Crystal Bore (1.Z), Assembly Complex (2.Z), Repair Drone (2.S)
  12_economy           - Steel Bars->Plates two-step chain, Crafting Station=0 slots
  13_art_direction     - optimistic retro-futurism palette, animated systems
  14_ui_systems        - Production Dashboard, offline sim (30s steps, 960-step cap)
  15_save_load         - serialization list, autosave, prestige persistence rules
  16_input_map         - all key bindings, controller map, uniqueness rule enforced
  17_world_generation  - hand-crafted maps A1/B/C/A2, deposit spawn rules, data files

Contradictions resolved (9): [O]/[B] key conflict, cargo ship construction method,
Repair Drone existence, drone carry capacity, FL in BER formula, auto-dispatch phase,
Steel Bars naming, Planet B water recipe, Planet C prestige survey data

Gameplay engine changes:
- Fullscreen: CANVAS_ITEMS scaling, F11 toggle, DEFAULT_FULLSCREEN=true
- Procedural asteroid background (asteroid_background.gd)
- OptionsPanel wired into main menu
- Building labels enlarged + brightened
- Player spawn moved from SellTerminal range

CI/CD:
- .github/workflows/web_export.yml (Godot 4.6.2 web build auto-deploys to GitHub Pages)
- Live at: https://grimatoma.github.io/VoidYield/ (enable Pages in repo settings first)

Design mockups (design_mocks/): 13 SVG diagrams in amber/retro-futurism palette"

echo.
echo Pushing to GitHub...
git push origin main

echo.
if %ERRORLEVEL%==0 (
    echo.
    echo SUCCESS! Everything is on GitHub.
    echo.
    echo Next step: go to github.com/grimatoma/VoidYield/settings/pages
    echo Set Source to "GitHub Actions" to enable the web build deploy.
    echo Game will be live at: https://grimatoma.github.io/VoidYield/
) else (
    echo.
    echo PUSH FAILED - check your GitHub credentials.
    echo Try running: git push origin main
)
pause
