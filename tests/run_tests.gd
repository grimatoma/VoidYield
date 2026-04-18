extends Node
## Test-suite entry point.
##
## Usage:
##   Godot_v4.6.2-stable_win64.exe --path . res://tests/run_tests.tscn -- --unit-only
##   Godot_v4.6.2-stable_win64.exe --path . res://tests/run_tests.tscn -- --update-golden
##
## Arguments after `--` are forwarded via OS.get_cmdline_user_args() and
## parsed by TestRunner.
##
## On completion the process exits with code 0 (all tests passed) or 1 (any
## failure). This lets CI tooling treat the exit code as a pass/fail signal.

const TestRunnerScript := preload("res://tests/framework/test_runner.gd")


func _ready() -> void:
	# SaveManager autoload loads user://save.json on ready; for tests we always
	# want a clean slate so previous play sessions don't leak into tests.
	var sm := get_node_or_null("/root/SaveManager")
	if sm and sm.has_method("delete_save"):
		sm.delete_save()

	# Construct & attach the runner.
	var runner: Node = TestRunnerScript.new()
	add_child(runner)
	runner.finished.connect(_on_runner_finished)
	await get_tree().process_frame
	await runner.run()


func _on_runner_finished(exit_code: int) -> void:
	# Defer exit a tick so final prints flush.
	await get_tree().process_frame
	get_tree().quit(exit_code)
