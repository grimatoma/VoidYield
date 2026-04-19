extends "res://tests/framework/test_case.gd"
## Unit tests for GalaxyMap system.

const GalaxyMapScript = preload("res://autoloads/galaxy_map.gd")


func test_galaxy_map_has_a1() -> void:
	var galaxy = GalaxyMapScript.new()
	assert_has(galaxy.planets, "a1", "Should have A1")


func test_galaxy_map_has_planet_b_after_rocket_ready() -> void:
	var galaxy = GalaxyMapScript.new()
	galaxy.unlock_planet("planet_b")
	assert_has(galaxy.planets, "planet_b", "Should unlock Planet B when rocket is ready")


func test_galaxy_map_a1_is_always_current() -> void:
	var galaxy = GalaxyMapScript.new()
	assert_eq(galaxy.current_planet, "a1", "Should start on A1")


func test_galaxy_map_can_travel_to_unlocked_planet() -> void:
	var galaxy = GalaxyMapScript.new()
	galaxy.unlock_planet("planet_b")
	var success = galaxy.travel_to("planet_b")
	assert_true(success, "Should travel to unlocked planet")
	assert_eq(galaxy.current_planet, "planet_b", "Should update current planet")


func test_galaxy_map_cannot_travel_to_locked_planet() -> void:
	var galaxy = GalaxyMapScript.new()
	var success = galaxy.travel_to("planet_b")
	assert_false(success, "Should not travel to locked planet")
	assert_eq(galaxy.current_planet, "a1", "Should stay on A1")
