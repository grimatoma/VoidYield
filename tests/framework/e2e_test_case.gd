class_name E2ETestCase
extends "res://tests/framework/test_case.gd"
## Base class for E2E / integration tests.
##
## Instantiates the Main scene (or a custom scene) into a Window child of the
## test entry node, so the real game runs while the runner oversees it.
## Provides golden-screenshot comparison plumbing.

const IMAGE_DIFF := preload("res://tests/framework/image_diff.gd")
const VIRTUAL_INPUT := preload("res://tests/framework/virtual_input.gd")

const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const GOLDEN_DIR := "res://tests/golden"
const ACTUALS_DIR := "user://tests/actuals"
const DIFFS_DIR := "user://tests/diffs"

# Set by the runner before the suite starts.
var update_golden: bool = false

# The running Main scene instance (spawned in before_each).
var main_scene: Node = null


func set_runner_flags(update_golden_flag: bool) -> void:
	update_golden = update_golden_flag


# --- Scene lifecycle -------------------------------------------------------

func load_main_scene() -> Node:
	## Load and attach a fresh Main scene, reset game state first.
	reset_game_state()

	var scene: PackedScene = load(MAIN_SCENE_PATH)
	assert_not_null(scene, "failed to preload Main scene")
	if scene == null:
		return null

	# Attach as a child of the scene tree root so autoloads see it as the
	# active game. Remove any prior test scene first.
	unload_main_scene()

	main_scene = scene.instantiate()
	get_tree().root.add_child(main_scene)

	# Give Main._ready's deferred world-load a moment (2 process_frame awaits
	# inside main.gd's _load_world) plus a frame for HUD wiring.
	await wait_frames(6)
	return main_scene


func unload_main_scene() -> void:
	if main_scene != null and is_instance_valid(main_scene):
		main_scene.queue_free()
		main_scene = null
		await wait_frames(2)


# --- Panel helpers ---------------------------------------------------------

func get_shop_panel() -> Node:
	return get_tree().get_first_node_in_group("shop_panel")

func get_spaceship_panel() -> Node:
	return get_tree().get_first_node_in_group("spaceship_panel")

func get_galaxy_map_panel() -> Node:
	return get_tree().get_first_node_in_group("galaxy_map_panel")

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group("player")


## Wait until `predicate.call()` returns true, or `max_seconds` elapses.
## Returns true on success.
func wait_until(predicate: Callable, max_seconds: float = 2.0) -> bool:
	var start := Time.get_ticks_msec()
	while Time.get_ticks_msec() - start < int(max_seconds * 1000.0):
		if predicate.call():
			return true
		await get_tree().process_frame
	return predicate.call()


# --- Screenshot & golden comparison ---------------------------------------

## Grab the current viewport as an Image, flipped upright.
func take_screenshot() -> Image:
	# Allow two frames so any just-triggered redraw commits before capture.
	await wait_frames(2)
	var viewport := get_viewport()
	if viewport == null:
		return null
	var tex := viewport.get_texture()
	if tex == null:
		return null
	var img := tex.get_image()
	return img


## Compare the current viewport against tests/golden/<name>.png.
## * If the golden is missing or `update_golden` is on, writes the current
##   screenshot as the new golden (pass).
## * Otherwise runs ImageDiff.compare and records failure on mismatch,
##   saving actual + diff PNGs to user://tests/ for inspection.
func assert_screenshot_matches(golden_name: String,
		pixel_tolerance: int = IMAGE_DIFF.DEFAULT_PIXEL_TOLERANCE,
		fraction_tolerance: float = IMAGE_DIFF.DEFAULT_FRACTION_TOLERANCE) -> bool:
	var actual: Image = await take_screenshot()
	if actual == null:
		fail("screenshot capture returned null")
		return false

	var golden_path := "%s/%s.png" % [GOLDEN_DIR, golden_name]
	var actual_path := "%s/%s.png" % [ACTUALS_DIR, golden_name]
	var diff_path := "%s/%s.diff.png" % [DIFFS_DIR, golden_name]

	# Always persist the actual so CI artefacts can show it.
	IMAGE_DIFF.save_png(actual, actual_path)

	var golden: Image = IMAGE_DIFF.load_png(golden_path)

	if golden == null or update_golden:
		# Establish / refresh the golden. We write to the source-tree path via
		# ProjectSettings.globalize_path so the new image lives next to other
		# goldens in the repo.
		var write_path := ProjectSettings.globalize_path(golden_path)
		DirAccess.make_dir_recursive_absolute(write_path.get_base_dir())
		var err := actual.save_png(write_path)
		if err != OK:
			fail("failed to write golden to %s (err=%d)" % [write_path, err])
			return false
		print("    [golden] wrote %s" % write_path)
		return true

	var result = IMAGE_DIFF.compare(actual, golden, pixel_tolerance, fraction_tolerance)
	if result.matches:
		return true

	if result.diff_image != null:
		IMAGE_DIFF.save_png(result.diff_image, diff_path)
	fail("screenshot mismatch for '%s' — %s (actual=%s diff=%s)" % [
		golden_name, result.reason,
		ProjectSettings.globalize_path(actual_path),
		ProjectSettings.globalize_path(diff_path),
	])
	return false
