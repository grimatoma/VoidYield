class_name AssemblyComplex
extends Node2D
## Assembly Complex — 3-input factory with proximity bonus (M13, tech 2.Z).

const FACTORY_TIER: int = 3
const SLOT_COUNT: int = 3
const SLOT_COST: int = 3
const OUTPUT_BUFFER_CAP: int = 20
const PROXIMITY_RADIUS: float = 80.0
const PROXIMITY_BONUS: float = 1.1

var current_recipe_id: String = ""
var is_running: bool = false

var _progress: float = 0.0
var _input_buffer: Dictionary = {}
var _output_buffer: Dictionary = {}
var _input_sources: Array = []  # Stores positions of input sources

signal cycle_completed(recipe_id: String, outputs: Dictionary)


func set_recipe(recipe_id: String) -> bool:
	if not recipe_id in Recipes.ALL:
		return false
	var recipe = Recipes.ALL[recipe_id]
	if recipe.get("factory_tier") != FACTORY_TIER:
		return false
	current_recipe_id = recipe_id
	return true


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


func get_proximity_bonus() -> float:
	# Bonus if all 3 input sources within 80 px of assembly complex
	if _input_sources.size() >= 3:
		var all_close = true
		for source_pos in _input_sources:
			if global_position.distance_to(source_pos) > PROXIMITY_RADIUS:
				all_close = false
				break
		if all_close:
			return PROXIMITY_BONUS
	return 1.0


func tick(delta: float) -> void:
	if not is_running:
		return

	if not can_run():
		return

	var proximity_mult = get_proximity_bonus()
	_progress += delta * proximity_mult
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

	# Add outputs with proximity bonus applied
	var proximity_mult = get_proximity_bonus()
	for resource_type in outputs:
		var amount = outputs[resource_type]
		var modified = maxi(1, int(amount * proximity_mult))
		_output_buffer[resource_type] = _output_buffer.get(resource_type, 0) + modified

	cycle_completed.emit(current_recipe_id, outputs)

	# Reset progress for next cycle
	_progress = 0.0


func register_input_source(source_position: Vector2) -> void:
	_input_sources.append(source_position)
