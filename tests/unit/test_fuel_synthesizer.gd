extends "res://tests/framework/test_case.gd"
## Unit tests for Fuel Synthesizer recipe integration.

const ProcessingPlantScript = preload("res://scenes/world/processing_plant.gd")


func test_fuel_synthesizer_recipe_exists() -> void:
	assert_has(Recipes.ALL, "fuel_synthesis", "Fuel Synthesizer recipe should exist")


func test_fuel_synthesizer_is_tier1() -> void:
	var recipe = Recipes.ALL.get("fuel_synthesis", {})
	assert_eq(recipe.get("factory_tier"), 1, "Should be tier-1 recipe")


func test_fuel_synthesizer_requires_compressed_gas() -> void:
	var recipe = Recipes.ALL.get("fuel_synthesis", {})
	var inputs = recipe.get("inputs", {})
	assert_has(inputs, "compressed_gas", "Should require compressed_gas")


func test_fuel_synthesizer_produces_rocket_fuel() -> void:
	var recipe = Recipes.ALL.get("fuel_synthesis", {})
	var outputs = recipe.get("outputs", {})
	assert_has(outputs, "rocket_fuel", "Should produce rocket_fuel")


func test_processing_plant_can_run_fuel_synthesizer() -> void:
	var plant = ProcessingPlantScript.new()
	plant.set_recipe("fuel_synthesis")
	plant.load_input("compressed_gas", 20)  # Recipe requires some amount
	assert_true(plant.can_run(), "Should be able to run fuel_synthesis recipe")
