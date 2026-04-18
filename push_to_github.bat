@echo off
REM VoidYield — commit all outstanding changes and push to GitHub
REM Double-click this when you get back to your computer.

cd /d "%~dp0"

echo Clearing stale git locks (from Godot editor)...
if exist ".git\HEAD.lock" del /f ".git\HEAD.lock"
if exist ".git\index.lock" del /f ".git\index.lock"
if exist ".git\objects\maintenance.lock" del /f ".git\objects\maintenance.lock"

echo.
echo Staging all changes...
git add -A

echo.
echo Committing everything...
git commit -m "feat: game systems overhaul + design doc

Gameplay & engine:
- Fullscreen support: CANVAS_ITEMS scaling (960x540 base), F11 toggle,
  DEFAULT_FULLSCREEN=true, window/size/mode=3 in project.godot
- Procedural asteroid background: 4-tone rock tiles, 55 craters,
  28 glowing fissures, 90 crystals (drawn in _draw(), no textures)
- OptionsPanel: audio sliders + fullscreen toggle, wired into main menu
- Building labels: 8px to 10-11px, brighter colours
- Player spawn moved to Vector2(700,450) - away from SellTerminal
- OutpostBorder brightened

New sprites and assets:
- Rock/ground tiles: rock_large, rock_medium, rock_small
- Ground tiles: asteroid_field, outpost_edge, outpost_floor, planet_b, space_bg
- Building/ore/player sprite imports

Game design:
- GAME_DESIGN.md: 18-section GDD covering full automation-incremental
  design (SWG ore quality, surveying, harvesters, drone swarms,
  vehicles, crafting quality, rocket construction, planet stranding)
- design_mocks/: 8 SVG diagrams in amber CRT palette

Other:
- Updated .gitignore (exclude .vscode, .claude/worktrees, *.skill)
- Various scene, autoload, and test file updates from prior sessions"

echo.
echo Pushing to GitHub...
git push origin main

echo.
if %ERRORLEVEL%==0 (
    echo SUCCESS - all commits pushed to GitHub!
) else (
    echo PUSH FAILED - you may need to authenticate.
    echo Try: git push origin main
)
pause
