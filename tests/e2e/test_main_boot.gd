extends "res://tests/framework/e2e_test_case.gd"
## Smoke tests for the Main scene: asserts the scene boots cleanly, the player
## is spawned into the asteroid field, HUD/panels are instantiated in the
## correct groups, and captures a golden screenshot of the initial state.

func before_each() -> void:
	await load_main_scene()


func after_each() -> void:
	await unload_main_scene()


func test_player_spawns_in_asteroid_field() -> void:
	var player := get_player()
	assert_not_null(player, "player should spawn after Main _ready")
	if player == null:
		return
	# Default spawn position defined in main.gd DESTINATIONS["asteroid_a1"].
	assert_near(player.global_position.x, 280.0, 2.0)
	assert_near(player.global_position.y, 420.0, 2.0)


func test_hud_and_panels_registered() -> void:
	assert_not_null(get_shop_panel(), "ShopPanel not in group")
	assert_not_null(get_spaceship_panel(), "SpaceshipPanel not in group")
	assert_not_null(get_galaxy_map_panel(), "GalaxyMapPanel not in group")


func test_initial_current_planet_is_a1() -> void:
	assert_eq(GameState.current_planet, "asteroid_a1")


func test_initial_hud_matches_golden() -> void:
	# Wait an extra moment so the async _setup_navigation baking finishes and
	# the HUD labels update to their initial values.
	await wait_seconds(0.4)
	await assert_screenshot_matches("hud_initial",
		8,     # pixel tolerance — AA on labels varies a touch
		0.02)  # 2% of pixels may differ
