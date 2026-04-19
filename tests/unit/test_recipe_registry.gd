extends "res://tests/framework/test_case.gd"
## Unit tests for RecipeRegistry autoload.

const RecipeRegistryScript = preload("res://autoloads/recipe_registry.gd")


func test_get_recipe_returns_recipe_data() -> void:
	var registry = RecipeRegistryScript.new()
	var recipe = registry.get_recipe("smelt_vorax")
	assert_not_null(recipe, "Should return recipe data")
	assert_eq(recipe.get("factory_tier"), 1, "Should have factory_tier")


func test_get_recipe_returns_null_for_unknown_recipe() -> void:
	var registry = RecipeRegistryScript.new()
	var recipe = registry.get_recipe("nonexistent_recipe")
	assert_null(recipe, "Should return null for unknown recipe")


func test_get_recipes_for_tier_returns_tier1_recipes() -> void:
	var registry = RecipeRegistryScript.new()
	var recipes = registry.get_recipes_for_tier(1)
	assert_gt(recipes.size(), 0, "Should return tier-1 recipes")
	for recipe_id in recipes:
		var recipe = Recipes.ALL[recipe_id]
		assert_eq(recipe.get("factory_tier"), 1, "All recipes should be tier-1")


func test_get_recipes_for_tier_returns_tier2_recipes() -> void:
	var registry = RecipeRegistryScript.new()
	var recipes = registry.get_recipes_for_tier(2)
	assert_gt(recipes.size(), 0, "Should return tier-2 recipes")
	for recipe_id in recipes:
		var recipe = Recipes.ALL[recipe_id]
		assert_eq(recipe.get("factory_tier"), 2, "All recipes should be tier-2")


func test_get_recipes_for_tier_includes_new_recipes() -> void:
	var registry = RecipeRegistryScript.new()
	var recipes = registry.get_recipes_for_tier(2)
	assert_has(recipes, "craft_surveyor", "Should include craft_surveyor")
	assert_has(recipes, "craft_fuel_cell", "Should include craft_fuel_cell")
	assert_has(recipes, "craft_drone_frame", "Should include craft_drone_frame")


func test_can_craft_returns_true_with_inputs() -> void:
	var registry = RecipeRegistryScript.new()
	var inputs = {"steel_bar": 5, "krysite_ingot": 1}
	var can_craft = registry.can_craft("craft_surveyor", inputs)
	assert_true(can_craft, "Should be able to craft with sufficient inputs")


func test_can_craft_returns_false_with_missing_inputs() -> void:
	var registry = RecipeRegistryScript.new()
	var inputs = {"steel_bar": 1}  # Only 1, need 3 for craft_surveyor
	var can_craft = registry.can_craft("craft_surveyor", inputs)
	assert_false(can_craft, "Should not craft with missing inputs")


func test_can_craft_returns_false_for_unknown_recipe() -> void:
	var registry = RecipeRegistryScript.new()
	var inputs = {"steel_bar": 5}
	var can_craft = registry.can_craft("nonexistent_recipe", inputs)
	assert_false(can_craft, "Should return false for unknown recipe")
