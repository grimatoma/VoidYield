extends "res://tests/framework/e2e_test_case.gd"
## E2E tests for the spaceship crafting panel:
##   - opens cleanly
##   - LAUNCH button is disabled until all parts are built
##   - wiring launch_requested → Main opens the galaxy map

const _VIRT := preload("res://tests/framework/virtual_input.gd")


func before_each() -> void:
	await load_main_scene()


func after_each() -> void:
	await unload_main_scene()


func _open_ship_panel() -> Node:
	var panel := get_spaceship_panel()
	assert_not_null(panel)
	panel.open()
	await wait_seconds(0.3)
	return panel


func test_launch_disabled_until_ship_ready() -> void:
	var panel := await _open_ship_panel()
	assert_true(panel.is_open)
	assert_true(panel.launch_button.disabled, "launch should start disabled")
	assert_false(GameState.is_ship_ready())


func test_launch_enables_after_all_parts_crafted() -> void:
	var panel := await _open_ship_panel()
	# Force-complete all parts and re-populate.
	for part_id in GameState.spaceship_parts_crafted:
		GameState.spaceship_parts_crafted[part_id] = true
	panel._populate()
	await wait_frames(2)

	assert_false(panel.launch_button.disabled, "launch should be enabled")
	assert_eq(panel.launch_button.text, "LAUNCH → GALAXY MAP")


func test_launch_opens_galaxy_map() -> void:
	var panel := await _open_ship_panel()
	for part_id in GameState.spaceship_parts_crafted:
		GameState.spaceship_parts_crafted[part_id] = true
	panel._populate()
	await wait_frames(2)

	_VIRT.click_button(panel.launch_button)
	# Main listens on launch_requested and opens the galaxy map.
	var galaxy := get_galaxy_map_panel()
	assert_not_null(galaxy)
	var opened = await wait_until(func(): return galaxy.is_open, 2.0)
	assert_true(opened, "galaxy map should open after LAUNCH")


func test_spaceship_panel_golden() -> void:
	var _panel := await _open_ship_panel()
	await wait_seconds(0.25)
	await assert_screenshot_matches("spaceship_panel_empty", 10, 0.03)
