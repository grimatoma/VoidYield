class_name RecipeRegistry
extends RefCounted
## Registry for accessing recipes by ID, tier, and checking crafting requirements.


func get_recipe(recipe_id: String) -> Dictionary:
	if recipe_id in Recipes.ALL:
		return Recipes.ALL[recipe_id]
	return null


func get_recipes_for_tier(tier: int) -> Array:
	var recipes = []
	for recipe_id in Recipes.ALL:
		var recipe = Recipes.ALL[recipe_id]
		if recipe.get("factory_tier") == tier:
			recipes.append(recipe_id)
	return recipes


func can_craft(recipe_id: String, available_inputs: Dictionary) -> bool:
	var recipe = get_recipe(recipe_id)
	if recipe == null:
		return false
	
	var required_inputs = recipe.get("inputs", {})
	for input_type in required_inputs:
		var required = required_inputs[input_type]
		var available = available_inputs.get(input_type, 0)
		if available < required:
			return false
	
	return true
