class_name ProcessingPlant
extends Node2D
## Tier 1 factory — single recipe continuous conversion.
## Uses recipe system from data/recipes.gd.

const FACTORY_TIER: int = 1
const SLOT_COST: int = 1
const OUTPUT_BUFFER_CAP: int = 20

var current_recipe_id: String = ""
var is_running: bool = false
var ore_quality: OreQualityLot = null

var _progress: float = 0.0
var _input_buffer: Dictionary = {}
var _output_buffer: Dictionary = {}

signal cycle_completed(recipe_id: String, outputs: Dictionary)


func set_recipe(recipe_id: String) -> bool:
	if not recipe_id in Recipes.ALL:
		return false
	var recipe = Recipes.ALL[recipe_id]
	if recipe.get("factory_tier") != FACTORY_TIER:
		return false
	current_recipe_id = recipe_id
	return true


func set_ore_quality(lot: OreQualityLot) -> void:
	ore_quality = lot


var effective_speed: float:
	get:
		return QualityModifiers.get_speed_modifier(ore_quality)


func load_input(resource_type: String, amount: int) -> int:
	var current = _input_buffer.get(resource_type, 0)
	_input_buffer[resource_type] = current + amount
	return amount


func can_run() -> bool:
	if current_recipe_id == "":
		return false

	var recipe = Recipes.ALL[current_recipe_id]
	var inputs = recipe.get("inputs", {})

	for resource_type in inputs:
		var required = inputs[resource_type]
		var available = _input_buffer.get(resource_type, 0)
		if available < required:
			return false

	# Check if output buffer has room
	var outputs = recipe.get("outputs", {})
	for resource_type in outputs:
		var current = _output_buffer.get(resource_type, 0)
		if current >= OUTPUT_BUFFER_CAP:
			return false

	return true


func tick(delta: float) -> void:
	if not is_running:
		return

	if not can_run():
		return

	var speed_mod = QualityModifiers.get_speed_modifier(ore_quality)
	_progress += delta * speed_mod
	var recipe = Recipes.ALL[current_recipe_id]
	var recipe_time = recipe.get("time", 0.0)

	if _progress >= recipe_time:
		_complete_cycle()


func start() -> void:
	is_running = true


func stop() -> void:
	is_running = false


func collect_output(resource_type: String, amount: int) -> int:
	var available = _output_buffer.get(resource_type, 0)
	var collected = mini(available, amount)
	_output_buffer[resource_type] = available - collected
	return collected


func _complete_cycle() -> void:
	var recipe = Recipes.ALL[current_recipe_id]
	var inputs = recipe.get("inputs", {})
	var outputs = recipe.get("outputs", {})

	# Consume inputs
	for resource_type in inputs:
		var required = inputs[resource_type]
		_input_buffer[resource_type] -= required

	# Add outputs with yield modifier
	var yield_mod = QualityModifiers.get_yield_modifier(ore_quality)
	var modified_outputs = {}
	for resource_type in outputs:
		var amount = outputs[resource_type]
		var modified = maxi(1, int(amount * yield_mod))
		_output_buffer[resource_type] = _output_buffer.get(resource_type, 0) + modified
		modified_outputs[resource_type] = modified

	# Emit signal with modified outputs
	cycle_completed.emit(current_recipe_id, modified_outputs)

	# Reset progress for next cycle
	_progress = 0.0
