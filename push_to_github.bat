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
git commit -m "design: 40 UI/gameplay SVG mocks + implementation roadmap (v0.5)

design_mocks/ui/ - 40 SVG mock-ups covering full game arc:
  Menus: main_menu, settings_menu, pause_menu
  HUD/overlays: hud_gameplay, production_overlay, coverage_overlay
  Panels: inventory, survey_tool, production_dashboard, tech_tree,
          fleet, drone_bay, resource_quality_inspector, event_log, save_load
  Galaxy/planet: galaxy_map, planet_select_tooltip
  Gameplay composites: mining_operation, factory_complex, drone_swarm,
    planet_b_landing, rocket_assembly, a1_start, first_harvester, manual_selling,
    survey_active, deposit_found, drone_v1, drone_v2_network, repair_drone,
    processing_plant, crafting_chain, quality_crafting, colony_early, colony_crisis,
    launchpad_building, planet_b_surface, interplanetary_logistics,
    warp_gate_construction, prestige_screen

docs/IMPLEMENTATION_ROADMAP.md - 627-line playable-first roadmap:
  15 milestones M0-M14, each ending with a testable game state
  Systems iterated across milestones (logistics v1/v2/v3, crafting v1/v2, etc.)
  Spec file reference index and cross-cutting concerns"

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
