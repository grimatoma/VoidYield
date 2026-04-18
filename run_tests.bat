@echo off
REM ----------------------------------------------------------------------
REM  VoidYield test runner (Windows).
REM
REM  Usage:
REM    run_tests.bat                  — run everything
REM    run_tests.bat --unit-only      — skip e2e screenshot tests
REM    run_tests.bat --e2e-only       — only e2e
REM    run_tests.bat --update-golden  — refresh golden screenshots
REM    run_tests.bat --filter=shop    — only run suites whose name contains "shop"
REM
REM  Exit code 0 = all passed, 1 = failures, 2 = Godot launch failed.
REM ----------------------------------------------------------------------

setlocal
set GODOT=%~dp0Godot_v4.6.2-stable_win64_console.exe
if not exist "%GODOT%" set GODOT=%~dp0Godot_v4.6.2-stable_win64.exe
if not exist "%GODOT%" (
    echo [run_tests] could not find Godot executable at %~dp0
    exit /b 2
)

pushd "%~dp0"
REM NOTE: pass user args AFTER a lone `--` so OS.get_cmdline_user_args picks them up.
"%GODOT%" --path . res://tests/run_tests.tscn -- %*
set RC=%ERRORLEVEL%
popd
exit /b %RC%
