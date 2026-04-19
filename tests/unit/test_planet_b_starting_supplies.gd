extends "res://tests/framework/test_case.gd"
## Unit tests for Planet B starting supplies system.

const PlanetBStartupScript = preload("res://autoloads/planet_b_startup.gd")


func test_planet_b_startup_provides_survey_tool() -> void:
	var startup = PlanetBStartupScript.new()
	var supplies = startup.get_starting_supplies()
	assert_has(supplies, "survey_tool", "Should include survey tool in starting supplies")


func test_planet_b_startup_provides_gas_canisters() -> void:
	var startup = PlanetBStartupScript.new()
	var supplies = startup.get_starting_supplies()
	assert_has(supplies, "gas_canisters", "Should include gas canisters")
	assert_eq(supplies["gas_canisters"], 5, "Should provide 5 gas canisters")


func test_planet_b_startup_provides_building_deeds() -> void:
	var startup = PlanetBStartupScript.new()
	var supplies = startup.get_starting_supplies()
	assert_has(supplies, "gas_collector_deed", "Should include gas collector deed")
	assert_has(supplies, "mineral_harvester_deed", "Should include mineral harvester deed")
	assert_has(supplies, "crafting_station_deed", "Should include crafting station deed")


func test_planet_b_startup_provides_materials() -> void:
	var startup = PlanetBStartupScript.new()
	var supplies = startup.get_starting_supplies()
	assert_has(supplies, "steel_plates", "Should include steel plates")
	assert_has(supplies, "alloy_rods", "Should include alloy rods")


func test_planet_b_startup_provides_starting_credits() -> void:
	var startup = PlanetBStartupScript.new()
	var supplies = startup.get_starting_supplies()
	assert_has(supplies, "credits", "Should include starting credits")
	assert_eq(supplies["credits"], 200, "Should provide 200 CR")
