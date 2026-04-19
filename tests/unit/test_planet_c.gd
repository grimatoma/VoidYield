extends "res://tests/framework/test_case.gd"
## TDD unit tests for Planet C scene (M13).

const PlanetCScript = preload("res://scenes/worlds/planet_c.gd")


func test_planet_c_world_size() -> void:
	var planet = PlanetCScript.new()
	assert_eq(planet.WORLD_WIDTH, 4000, "Planet C width should be 4000 px")
	assert_eq(planet.WORLD_HEIGHT, 3000, "Planet C height should be 3000 px")


func test_planet_c_industrial_sites() -> void:
	var planet = PlanetCScript.new()
	# 18 Industrial Sites total: 6 Western, 6 Rift, 6 Eastern
	assert_eq(planet.SITE_COUNT, 18, "Planet C should have 18 Industrial Sites")


func test_planet_c_has_void_touched_ore() -> void:
	var planet = PlanetCScript.new()
	assert_true(planet.has_method("get_void_touched_deposits"), "Planet C should have void-touched deposits")


func test_planet_c_has_resonance_crystals() -> void:
	var planet = PlanetCScript.new()
	assert_true(planet.has_method("get_resonance_formations"), "Planet C should have resonance crystal formations")


func test_planet_c_has_dark_gas_geysers() -> void:
	var planet = PlanetCScript.new()
	# 8 Dark Gas Geysers
	assert_eq(planet.GEYSER_COUNT, 8, "Planet C should have 8 dark gas geysers")


func test_planet_c_shifting_deposits() -> void:
	var planet = PlanetCScript.new()
	assert_true(planet.has_method("trigger_deposit_shift"), "Planet C deposits should shift every 2-4 hours")


func test_planet_c_background_color() -> void:
	var planet = PlanetCScript.new()
	# Dark purple-blue atmosphere
	assert_eq(planet.background_color, "#3a2d5e", "Planet C background should be dark purple")


func test_planet_c_no_standard_gas() -> void:
	var planet = PlanetCScript.new()
	# Only Dark Gas from geysers, no standard gas deposits
	assert_false(planet.has_standard_gas_deposits(), "Planet C should have no standard gas")
