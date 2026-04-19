extends "res://tests/framework/test_case.gd"
## Unit tests for A3 unlock mechanics.

const A3UnlockScript = preload("res://autoloads/a3_unlock.gd")


func test_a3_not_unlocked_initially() -> void:
	var unlocks = A3UnlockScript.new()
	assert_false(unlocks.is_unlocked(), "A3 should not be unlocked initially")


func test_a3_unlocks_when_conditions_met() -> void:
	var unlocks = A3UnlockScript.new()
	unlocks.a2_visited = true
	unlocks.void_cores_produced = 10
	assert_true(unlocks.is_unlocked(), "A3 should unlock when visited A2 and 10 Void Cores produced")


func test_a3_requires_a2_visit() -> void:
	var unlocks = A3UnlockScript.new()
	unlocks.a2_visited = false
	unlocks.void_cores_produced = 10
	assert_false(unlocks.is_unlocked(), "A3 should require A2 visit")


func test_a3_requires_void_cores() -> void:
	var unlocks = A3UnlockScript.new()
	unlocks.a2_visited = true
	unlocks.void_cores_produced = 9
	assert_false(unlocks.is_unlocked(), "A3 should require 10 Void Cores")


func test_a3_get_unlock_progress() -> void:
	var unlocks = A3UnlockScript.new()
	unlocks.void_cores_produced = 5
	var progress = unlocks.get_progress()
	assert_eq(progress["void_cores"], "5/10", "Should show void core progress")
	assert_eq(progress["a2_visited"], false, "Should show A2 visit status")
