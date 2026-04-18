extends "res://tests/framework/test_case.gd"
## TDD unit tests for the SaveManager autoload.
## Covers: has_save, save_game_immediate, load roundtrip, version mismatch,
##         delete_save, two-slot isolation.

func before_each() -> void:
	reset_game_state()
	SaveManager.delete_save()


func after_each() -> void:
	SaveManager.delete_save()


# --- has_save ----------------------------------------------------------------

func test_has_save_false_when_no_file() -> void:
	assert_false(SaveManager.has_save(), "no save file should exist after delete")


func test_has_save_true_after_immediate_save() -> void:
	SaveManager.save_game_immediate()
	assert_true(SaveManager.has_save())


# --- save_game_immediate -----------------------------------------------------

func test_save_immediate_bypasses_cooldown() -> void:
	## Even rapid back-to-back calls should both write (no throttle).
	GameState.credits = 111
	SaveManager.save_game_immediate()
	GameState.credits = 222
	SaveManager.save_game_immediate()

	reset_game_state()
	assert_eq(GameState.credits, 0, "state cleared between saves and reload")

	SaveManager.load_game()
	assert_eq(GameState.credits, 222, "last written value wins")


# --- save / load roundtrip ---------------------------------------------------

func test_save_and_load_preserves_credits() -> void:
	GameState.credits = 7654
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.credits, 7654)


func test_save_and_load_preserves_inventory() -> void:
	GameState.player_max_carry  = 30
	GameState.player_carried_ore = 12
	GameState.player_rare_ore    = 5
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.player_max_carry,   30)
	assert_eq(GameState.player_carried_ore, 12)
	assert_eq(GameState.player_rare_ore,     5)


func test_save_and_load_preserves_storage_pool() -> void:
	GameState.storage_capacity  = 200
	GameState.storage_ore       = 60
	GameState.storage_rare_ore  = 20
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.storage_capacity, 200)
	assert_eq(GameState.storage_ore,       60)
	assert_eq(GameState.storage_rare_ore,  20)


func test_save_and_load_preserves_ship_parts() -> void:
	GameState.spaceship_parts_crafted["hull_plating"] = true
	GameState.spaceship_parts_crafted["ion_drive"]    = true
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_true(GameState.spaceship_parts_crafted["hull_plating"])
	assert_true(GameState.spaceship_parts_crafted["ion_drive"])
	assert_false(GameState.spaceship_parts_crafted["navigation_core"])


func test_save_and_load_preserves_upgrades() -> void:
	GameState.purchased_upgrades = {"cargo_pockets": 2, "fleet_license": 1}
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.purchased_upgrades.get("cargo_pockets"), 2)
	assert_eq(GameState.purchased_upgrades.get("fleet_license"), 1)


func test_save_and_load_preserves_current_planet() -> void:
	GameState.current_planet = "planet_b"
	SaveManager.save_game_immediate()
	reset_game_state()
	SaveManager.load_game()
	assert_eq(GameState.current_planet, "planet_b")


# --- Version mismatch --------------------------------------------------------

func test_version_mismatch_wipes_save_file() -> void:
	## Write a v0.1 payload directly, then call load_game().
	## Expect: file is deleted, no data loaded.
	GameState.credits = 100
	var old_payload := {
		"version": "0.1",   # old; current = "0.2"
		"timestamp": 0,
		"game_state": GameState.get_save_data(),
	}
	var file := FileAccess.open("user://save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(old_payload))
		file.close()

	assert_true(SaveManager.has_save(), "file written before load")

	reset_game_state()
	SaveManager.load_game()  # should wipe

	assert_false(SaveManager.has_save(), "file removed after version mismatch")
	assert_eq(GameState.credits, 0, "no data from old save loaded")


func test_corrupted_json_does_not_crash() -> void:
	## Write garbage bytes — load_game() should warn but not throw.
	var file := FileAccess.open("user://save.json", FileAccess.WRITE)
	if file:
		file.store_string("{{NOT VALID JSON{{")
		file.close()

	reset_game_state()
	GameState.credits = 0
	SaveManager.load_game()  # should silently fail, not crash

	# State unchanged from reset; credits should still be 0
	assert_eq(GameState.credits, 0, "corrupted save leaves state untouched")


# --- delete_save -------------------------------------------------------------

func test_delete_save_removes_main_slot() -> void:
	SaveManager.save_game_immediate()
	assert_true(FileAccess.file_exists("user://save.json"))
	SaveManager.delete_save()
	assert_false(FileAccess.file_exists("user://save.json"))


func test_delete_save_removes_autosave_slot() -> void:
	## Create an autosave stub and verify delete_save removes it too.
	var auto_file := FileAccess.open("user://save_auto.json", FileAccess.WRITE)
	if auto_file:
		auto_file.store_string("{}")
		auto_file.close()
	SaveManager.delete_save()
	assert_false(FileAccess.file_exists("user://save_auto.json"))


func test_delete_save_is_idempotent_when_no_files() -> void:
	## Calling delete when nothing exists must not error.
	SaveManager.delete_save()
	SaveManager.delete_save()  # second call — no crash expected
	assert_false(SaveManager.has_save())


# --- load_game with no file --------------------------------------------------

func test_load_game_with_no_file_leaves_state_unchanged() -> void:
	SaveManager.delete_save()
	GameState.credits = 42
	SaveManager.load_game()
	assert_eq(GameState.credits, 42, "state unmodified when no file found")
