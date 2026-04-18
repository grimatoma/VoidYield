extends "res://tests/framework/e2e_test_case.gd"
## E2E tests for the Galaxy Map panel CUJ:
##   - opens and draws correctly (background rendered beneath planet/route layer)
##   - selecting a body updates the action panel
##   - clicking TRAVEL transitions current_planet and re-loads the world
##   - A3 is locked and cannot be travelled to
##
## Full CUJ tests (end-to-end journeys):
##   test_cuj_craft_launch_select_travel   — A1 → craft parts → LAUNCH → map → Planet B
##   test_cuj_launch_pad_return_to_a1      — Planet B launch pad → map → back to A1

const _VIRT := preload("res://tests/framework/virtual_input.gd")


func before_each() -> void:
	await load_main_scene()


func after_each() -> void:
	await unload_main_scene()


func _open_galaxy() -> Node:
	var g := get_galaxy_map_panel()
	assert_not_null(g)
	g.open()
	await wait_seconds(0.3)
	return g


func test_opens_and_shows_three_bodies() -> void:
	var g := await _open_galaxy()
	assert_true(g.is_open)
	assert_eq(g._body_buttons.size(), g.PLANETS.size())


func test_select_body_updates_action_panel() -> void:
	var g := await _open_galaxy()
	# Select Planet B (index 1) via the public interaction helper.
	g._on_body_pressed(1)
	await wait_frames(2)
	assert_eq(g._selected_index, 1)
	assert_false(g._travel_button.disabled,
		"Planet B is travelable from the default A1 location")


func test_cannot_travel_to_locked_planet() -> void:
	var g := await _open_galaxy()
	# Index 2 = A3 unknown / locked.
	g._on_body_pressed(2)
	await wait_frames(2)
	assert_true(g._travel_button.disabled, "locked bodies must not be travelable")


func test_cannot_travel_to_current_location() -> void:
	var g := await _open_galaxy()
	# Current planet is asteroid_a1 → body index 0.
	g._on_body_pressed(0)
	await wait_frames(2)
	assert_true(g._travel_button.disabled, "already at A1 — TRAVEL disabled")


func test_travel_to_planet_b_transitions_world() -> void:
	var g := await _open_galaxy()
	g._on_body_pressed(1)
	await wait_frames(2)
	_VIRT.click_button(g._travel_button)
	# _load_world awaits 2 process_frames before instantiating new world.
	var arrived = await wait_until(func():
		return GameState.current_planet == "planet_b" \
			and get_player() != null, 3.0)
	assert_true(arrived, "expected current_planet to flip to planet_b")


func test_galaxy_map_golden() -> void:
	var _g := await _open_galaxy()
	await wait_seconds(0.3)
	await assert_screenshot_matches("galaxy_map_default", 10, 0.04)


# ---------------------------------------------------------------------------
# Full CUJ tests
# ---------------------------------------------------------------------------

func test_cuj_craft_launch_select_travel() -> void:
	## CUJ: player finishes crafting all ship parts, clicks LAUNCH → GALAXY MAP
	## on the spaceship panel, selects Planet B, clicks TRAVEL, and the world
	## transitions to Planet B with the player spawned there.

	# --- 1. Force-complete all ship parts (simulates prior crafting session) ---
	for part_id in GameState.spaceship_parts_crafted:
		GameState.spaceship_parts_crafted[part_id] = true

	# --- 2. Open the spaceship panel (as if the player walked up to the ship) ---
	var ship_panel := get_spaceship_panel()
	assert_not_null(ship_panel, "SpaceshipPanel must be in the scene")
	ship_panel.open()
	await wait_frames(4)
	assert_true(ship_panel.is_open, "spaceship panel should be open")

	# --- 3. Verify LAUNCH button text & enabled state ---
	assert_false(ship_panel.launch_button.disabled,
		"LAUNCH button must be enabled when all parts are built")
	assert_eq(ship_panel.launch_button.text, "LAUNCH → GALAXY MAP",
		"button text should reflect ready-to-launch state")

	# --- 4. Click LAUNCH — Main should open the galaxy map ---
	_VIRT.click_button(ship_panel.launch_button)
	var galaxy := get_galaxy_map_panel()
	assert_not_null(galaxy, "GalaxyMapPanel must be in the scene")
	var galaxy_opened := await wait_until(func(): return galaxy.is_open, 2.0)
	assert_true(galaxy_opened, "galaxy map should open after clicking LAUNCH")
	assert_false(ship_panel.is_open, "spaceship panel should close when LAUNCH is clicked")

	# --- 5. Galaxy map has the expected number of bodies ---
	assert_eq(galaxy._body_buttons.size(), galaxy.PLANETS.size(),
		"galaxy map should show one button per planet")

	# --- 6. Action panel starts with no selection → TRAVEL disabled ---
	assert_true(galaxy._travel_button.disabled,
		"TRAVEL must be disabled until a destination is selected")

	# --- 7. Select Planet B (A2, index 1) ---
	galaxy._on_body_pressed(1)
	await wait_frames(2)
	assert_eq(galaxy._selected_index, 1, "Planet B should be selected")
	assert_false(galaxy._travel_button.disabled,
		"TRAVEL must be enabled when a travelable, non-current body is selected")

	# --- 8. Click TRAVEL — world should transition ---
	_VIRT.click_button(galaxy._travel_button)
	var arrived := await wait_until(func():
		return GameState.current_planet == "planet_b" and get_player() != null, 4.0)
	assert_true(arrived,
		"current_planet should switch to planet_b and player should spawn there")
	assert_false(galaxy.is_open, "galaxy map should close after travel begins")


func test_cuj_launch_pad_return_to_a1() -> void:
	## CUJ: player is on Planet B, interacts with the launch pad, galaxy map
	## opens, they select A1 and travel back.

	# --- 1. Teleport game state straight to Planet B ---
	# Wait until the planet_b world is fully instantiated (not just queued): we
	# check for the LaunchPad group member which only exists once planet_b.tscn
	# has been added to the tree.  Checking get_player() alone is not sufficient
	# because queue_free'd nodes from the old world can linger in the group list
	# for one frame.
	main_scene.call("_on_galaxy_travel_requested", "planet_b")
	var at_b := await wait_until(func():
		return GameState.current_planet == "planet_b" \
			and get_tree().get_first_node_in_group("launch_pad") != null, 4.0)
	assert_true(at_b, "should be on Planet B before testing the launch pad")

	# --- 2. Find and activate the launch pad ---
	var pad := get_tree().get_first_node_in_group("launch_pad")
	assert_not_null(pad, "Planet B should contain a LaunchPad in group 'launch_pad'")
	if pad == null:
		return
	_VIRT.interact_with(pad, get_player())
	await wait_frames(2)

	# --- 3. Galaxy map should be open ---
	var galaxy := get_galaxy_map_panel()
	assert_true(galaxy.is_open,
		"interacting with the launch pad should open the galaxy map")

	# --- 4. A1 (index 0) is travelable from Planet B ---
	galaxy._on_body_pressed(0)
	await wait_frames(2)
	assert_false(galaxy._travel_button.disabled,
		"TRAVEL to A1 should be enabled when standing on Planet B")

	# --- 5. Travel back to A1 ---
	_VIRT.click_button(galaxy._travel_button)
	var back_home := await wait_until(func():
		return GameState.current_planet == "asteroid_a1" and get_player() != null, 4.0)
	assert_true(back_home, "should return to A1 after travelling from Planet B launch pad")
